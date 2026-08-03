#!/bin/bash
set -e

# ─────────────────────────────────────────────
# Configurações do projeto BIA
# ─────────────────────────────────────────────
AWS_REGION="us-east-1"
ECR_URI="734421936978.dkr.ecr.us-east-1.amazonaws.com/bia"
PROJECT_DIR="$(dirname "$(realpath "$0")")"

# Cenário padrão (sem ALB)
TASK_DEF_FAMILY="task-def-bia"
ECS_CLUSTER="cluster-bia"
ECS_SERVICE="service-bia"

# Cenário com ALB
TASK_DEF_FAMILY_ALB="task-def-bia-alb"
ECS_CLUSTER_ALB="cluster-bia-alb"
ECS_SERVICE_ALB="service-bia-alb"
ALB_DNS="bia-alb-1101130261.us-east-1.elb.amazonaws.com"

# ─────────────────────────────────────────────
# Cores e estilos
# ─────────────────────────────────────────────
C_RESET="\033[0m"
C_BOLD="\033[1m"
C_BLUE="\033[1;34m"
C_GREEN="\033[1;32m"
C_YELLOW="\033[1;33m"
C_RED="\033[1;31m"
C_CYAN="\033[1;36m"
C_WHITE="\033[1;37m"
C_DIM="\033[2m"

# ─────────────────────────────────────────────
# Funções utilitárias
# ─────────────────────────────────────────────
log()     { echo -e "${C_BLUE}[INFO]${C_RESET}  $*"; }
success() { echo -e "${C_GREEN}[OK]${C_RESET}    $*"; }
warn()    { echo -e "${C_YELLOW}[WARN]${C_RESET}  $*"; }
error()   { echo -e "${C_RED}[ERROR]${C_RESET} $*"; exit 1; }

# Lê do terminal real (/dev/tty) quando disponível; caso contrário usa stdin.
# Isso permite que o script funcione tanto interativamente quanto via pipe/agente.
read_tty() {
  local prompt="$1"
  local varname="$2"
  local input
  if [ -e /dev/tty ] && { true </dev/tty; } 2>/dev/null; then
    IFS= read -r -p "$(echo -e "$prompt")" input </dev/tty
  else
    echo -ne "$prompt" >&2
    IFS= read -r input
  fi
  printf -v "$varname" '%s' "$input"
}

print_header() {
  local cluster="${1:-$ECS_CLUSTER}"
  local service="${2:-$ECS_SERVICE}"
  echo ""
  echo -e "  ${C_BOLD}${C_CYAN}╔═══════════════════════════════════════════════╗${C_RESET}"
  echo -e "  ${C_BOLD}${C_CYAN}║${C_RESET}          ${C_WHITE}${C_BOLD}🚀  BIA — Deploy com IA${C_RESET}             ${C_BOLD}${C_CYAN}║${C_RESET}"
  echo -e "  ${C_BOLD}${C_CYAN}║${C_RESET}  ${C_DIM}Cluster: ${cluster}  •  Serviço: ${service}${C_RESET}  ${C_BOLD}${C_CYAN}║${C_RESET}"
  echo -e "  ${C_BOLD}${C_CYAN}╚═══════════════════════════════════════════════╝${C_RESET}"
  echo ""
}

wait_service_stable() {
  log "Aguardando o serviço estabilizar (pode levar alguns minutos)..."
  aws ecs wait services-stable \
    --region "$AWS_REGION" \
    --cluster "$ECS_CLUSTER" \
    --services "$ECS_SERVICE"
  success "Serviço estável."
}

# ─────────────────────────────────────────────
# STATUS
# ─────────────────────────────────────────────
cmd_status() {
  echo ""
  echo -e "  ${C_BOLD}${C_CYAN}── Status do Serviço ECS ──────────────────────${C_RESET}"
  echo ""

  SERVICE_INFO=$(aws ecs describe-services \
    --region "$AWS_REGION" \
    --cluster "$ECS_CLUSTER" \
    --services "$ECS_SERVICE" \
    --query "services[0].[status, runningCount, desiredCount, taskDefinition, deployments[0].rolloutState]" \
    --output json)

  echo "$SERVICE_INFO" | python3 -c "
import json, sys
data = json.load(sys.stdin)
status        = data[0]
running       = data[1]
desired       = data[2]
task_def      = data[3].split('/')[-1] if data[3] else 'N/A'
rollout_state = data[4] if data[4] else 'N/A'

cor_status = '\033[1;32m' if status == 'ACTIVE' else '\033[1;33m'
cor_tasks  = '\033[1;32m' if running == desired else '\033[1;33m'
reset = '\033[0m'

print(f'  Serviço:         {cor_status}{status}{reset}')
print(f'  Tasks:           {cor_tasks}{running}/{desired} em execução{reset}')
print(f'  Task Definition: {task_def}')
print(f'  Rollout State:   {rollout_state}')
"
  echo ""
}

# ─────────────────────────────────────────────
# DEPLOY
# ─────────────────────────────────────────────
cmd_deploy() {
  echo ""
  echo -e "  ${C_BOLD}${C_CYAN}── Deploy ─────────────────────────────────────${C_RESET}"
  echo ""

  if ! git -C "$PROJECT_DIR" rev-parse --is-inside-work-tree &>/dev/null; then
    error "Diretório não é um repositório Git: $PROJECT_DIR"
  fi
  COMMIT_HASH=$(git -C "$PROJECT_DIR" rev-parse --short HEAD)
  COMMIT_MSG=$(git -C "$PROJECT_DIR" log -1 --pretty=format:"%s" 2>/dev/null || echo "N/A")
  IMAGE_URI="$ECR_URI:$COMMIT_HASH"

  echo -e "  ${C_DIM}Commit:${C_RESET}  ${C_BOLD}$COMMIT_HASH${C_RESET} — $COMMIT_MSG"
  echo -e "  ${C_DIM}Imagem:${C_RESET}  $IMAGE_URI"
  echo ""
  echo -e "  ${C_YELLOW}⚠  Confirma o deploy desta imagem para o ECS?${C_RESET}"
  echo ""
  echo -e "  ${C_CYAN}1)${C_RESET}  Sim, executar deploy"
  echo -e "  ${C_CYAN}0)${C_RESET}  Cancelar"
  echo ""

  while true; do
    read_tty "  ${C_BOLD}Escolha [0-1]:${C_RESET} " CONF
    case "$CONF" in
      1) break ;;
      0) warn "Deploy cancelado."; return ;;
      *) echo -e "  ${C_YELLOW}Opção inválida. Digite 0 ou 1.${C_RESET}" ;;
    esac
  done

  echo ""
  log "Iniciando deploy — commit: $COMMIT_HASH"

  log "Fazendo build da imagem..."
  docker build -t "$IMAGE_URI" "$PROJECT_DIR"
  success "Build concluído."

  log "Autenticando no ECR..."
  aws ecr get-login-password --region "$AWS_REGION" \
    | docker login --username AWS --password-stdin "$ECR_URI"
  success "Autenticado no ECR."

  log "Fazendo push da imagem para o ECR..."
  docker push "$IMAGE_URI"
  success "Push concluído: $IMAGE_URI"

  log "Adicionando tag latest..."
  IMAGE_LATEST="$ECR_URI:latest"
  docker tag "$IMAGE_URI" "$IMAGE_LATEST"
  docker push "$IMAGE_LATEST"
  success "Push concluído: $IMAGE_LATEST"

  log "Buscando configuração atual da task definition..."
  CURRENT_TASK_DEF=$(aws ecs describe-task-definition \
    --region "$AWS_REGION" \
    --task-definition "$TASK_DEF_FAMILY" \
    --query "taskDefinition" \
    --output json)

  NEW_TASK_DEF=$(echo "$CURRENT_TASK_DEF" | python3 -c "
import json, sys
td = json.load(sys.stdin)
for c in td['containerDefinitions']:
    c['image'] = '$IMAGE_URI'
for field in ['taskDefinitionArn','revision','status','requiresAttributes',
              'compatibilities','registeredAt','registeredBy','deregisteredAt']:
    td.pop(field, None)
print(json.dumps(td))
")

  log "Registrando nova revisão da task definition..."
  NEW_REVISION=$(aws ecs register-task-definition \
    --region "$AWS_REGION" \
    --cli-input-json "$NEW_TASK_DEF" \
    --query "taskDefinition.revision" \
    --output text)
  success "Nova revisão registrada: $TASK_DEF_FAMILY:$NEW_REVISION"

  log "Atualizando serviço ECS para $TASK_DEF_FAMILY:$NEW_REVISION..."
  aws ecs update-service \
    --region "$AWS_REGION" \
    --cluster "$ECS_CLUSTER" \
    --service "$ECS_SERVICE" \
    --task-definition "$TASK_DEF_FAMILY:$NEW_REVISION" \
    --output text --query "service.serviceName" > /dev/null
  success "Serviço atualizado."

  wait_service_stable

  echo ""
  echo -e "  ${C_GREEN}${C_BOLD}╔═══════════════════════════════════════════════╗${C_RESET}"
  echo -e "  ${C_GREEN}${C_BOLD}║        ✅  Deploy finalizado com sucesso!      ║${C_RESET}"
  echo -e "  ${C_GREEN}${C_BOLD}╠═══════════════════════════════════════════════╣${C_RESET}"
  echo -e "  ${C_GREEN}${C_BOLD}║${C_RESET}  Imagem:    ${C_BOLD}$COMMIT_HASH${C_RESET}"
  echo -e "  ${C_GREEN}${C_BOLD}║${C_RESET}  Revisão:   ${C_BOLD}$TASK_DEF_FAMILY:$NEW_REVISION${C_RESET}"
  echo -e "  ${C_GREEN}${C_BOLD}╚═══════════════════════════════════════════════╝${C_RESET}"
  echo ""
}

# ─────────────────────────────────────────────
# ROLLBACK
# ─────────────────────────────────────────────
cmd_rollback() {
  echo ""
  echo -e "  ${C_BOLD}${C_CYAN}── Rollback ───────────────────────────────────${C_RESET}"
  echo ""
  log "Buscando revisões disponíveis de $TASK_DEF_FAMILY..."

  REVISIONS=$(aws ecs list-task-definitions \
    --region "$AWS_REGION" \
    --family-prefix "$TASK_DEF_FAMILY" \
    --status ACTIVE \
    --sort DESC \
    --query "taskDefinitionArns[]" \
    --output json)

  REVISION_COUNT=$(echo "$REVISIONS" | python3 -c "import json,sys; print(len(json.load(sys.stdin)))")
  if [ "$REVISION_COUNT" -eq 0 ]; then
    error "Nenhuma revisão encontrada para $TASK_DEF_FAMILY."
  fi

  CURRENT_REVISION=$(aws ecs describe-services \
    --region "$AWS_REGION" \
    --cluster "$ECS_CLUSTER" \
    --services "$ECS_SERVICE" \
    --query "services[0].taskDefinition" \
    --output text | grep -oE '[0-9]+$')

  echo ""
  echo -e "  ${C_BOLD}Revisões disponíveis para ${C_CYAN}$TASK_DEF_FAMILY${C_RESET}${C_BOLD}:${C_RESET}"
  echo ""
  printf "  ${C_DIM}%-5s  %-10s  %-22s  %-35s  %s${C_RESET}\n" \
    "Nº" "REVISÃO" "DATA/HORA (UTC)" "IMAGEM (TAG)" "STATUS"
  echo -e "  ${C_DIM}────  ──────────  ──────────────────────  ───────────────────────────────────  ──────────${C_RESET}"

  echo "$REVISIONS" | python3 -c "
import json, sys, subprocess

arns = json.load(sys.stdin)
current = '$CURRENT_REVISION'
entries = []

for i, arn in enumerate(arns, start=1):
    result = subprocess.run(
        ['aws', 'ecs', 'describe-task-definition',
         '--region', '$AWS_REGION',
         '--task-definition', arn,
         '--query', 'taskDefinition.[revision, registeredAt, containerDefinitions[0].image]',
         '--output', 'json'],
        capture_output=True, text=True
    )
    data = json.loads(result.stdout)
    revision_num  = str(data[0])
    registered_at = data[1][:19].replace('T', ' ') if data[1] else 'N/A'
    image_tag     = data[2].split(':')[-1] if data[2] and ':' in data[2] else (data[2] or 'N/A')
    is_current    = revision_num == current

    cor_linha = '\033[1;32m' if is_current else '\033[0m'
    status    = '<-- EM USO' if is_current else ''
    reset     = '\033[0m'

    print(f'  {cor_linha}{i:<5} {revision_num:<10}  {registered_at:<22}  {image_tag:<35}  {status}{reset}')
    entries.append(revision_num)

import json as j2
with open('/tmp/bia_rollback_map.json','w') as f:
    j2.dump(entries, f)
"

  echo ""
  warn "Revisão atualmente em uso: $CURRENT_REVISION"
  echo ""
  echo -e "  ${C_DIM}Digite o número da linha (ex: 1) ou o número da revisão. ENTER para cancelar.${C_RESET}"
  echo ""

  while true; do
    read_tty "  ${C_BOLD}Revisão para rollback:${C_RESET} " CHOSEN

    if [ -z "$CHOSEN" ]; then
      warn "Rollback cancelado."
      return
    fi

    RESOLVED=$(python3 -c "
import json
try:
    entries = json.load(open('/tmp/bia_rollback_map.json'))
    chosen = '$CHOSEN'
    if chosen.isdigit() and 1 <= int(chosen) <= len(entries):
        idx = int(chosen) - 1
        if chosen not in entries:
            print(entries[idx])
        else:
            print(chosen)
    elif chosen in entries:
        print(chosen)
    else:
        print('INVALID')
except Exception:
    print('INVALID')
" 2>/dev/null)

    if [ "$RESOLVED" = "INVALID" ]; then
      echo -e "  ${C_YELLOW}Entrada inválida. Use o número da linha ou o número da revisão.${C_RESET}"
      continue
    fi
    break
  done

  if [ "$RESOLVED" = "$CURRENT_REVISION" ]; then
    warn "Revisão $RESOLVED já está em uso. Nenhuma alteração feita."
    return
  fi

  echo ""
  echo -e "  ${C_YELLOW}⚠  Confirma o rollback para ${C_BOLD}$TASK_DEF_FAMILY:$RESOLVED${C_RESET}${C_YELLOW}?${C_RESET}"
  echo ""
  echo -e "  ${C_CYAN}1)${C_RESET}  Sim, executar rollback"
  echo -e "  ${C_CYAN}0)${C_RESET}  Cancelar"
  echo ""

  while true; do
    read_tty "  ${C_BOLD}Escolha [0-1]:${C_RESET} " CONF
    case "$CONF" in
      1) break ;;
      0) warn "Rollback cancelado."; return ;;
      *) echo -e "  ${C_YELLOW}Opção inválida.${C_RESET}" ;;
    esac
  done

  log "Fazendo rollback para $TASK_DEF_FAMILY:$RESOLVED..."
  aws ecs update-service \
    --region "$AWS_REGION" \
    --cluster "$ECS_CLUSTER" \
    --service "$ECS_SERVICE" \
    --task-definition "$TASK_DEF_FAMILY:$RESOLVED" \
    --output text --query "service.serviceName" > /dev/null
  success "Serviço atualizado para $TASK_DEF_FAMILY:$RESOLVED."

  wait_service_stable

  echo ""
  echo -e "  ${C_GREEN}${C_BOLD}╔═══════════════════════════════════════════════╗${C_RESET}"
  echo -e "  ${C_GREEN}${C_BOLD}║       ✅  Rollback concluído com sucesso!      ║${C_RESET}"
  echo -e "  ${C_GREEN}${C_BOLD}╠═══════════════════════════════════════════════╣${C_RESET}"
  echo -e "  ${C_GREEN}${C_BOLD}║${C_RESET}  Revisão ativa:  ${C_BOLD}$TASK_DEF_FAMILY:$RESOLVED${C_RESET}"
  echo -e "  ${C_GREEN}${C_BOLD}╚═══════════════════════════════════════════════╝${C_RESET}"
  echo ""
}

# ─────────────────────────────────────────────
# Menu principal
# ─────────────────────────────────────────────
menu_pos_acao() {
  echo ""
  echo -e "  ${C_DIM}──────────────────────────────────────────────${C_RESET}"
  echo ""
  echo -e "  ${C_BOLD}O que deseja fazer agora?${C_RESET}"
  echo ""
  echo -e "  ${C_CYAN}1)${C_RESET}  Voltar ao menu principal"
  echo -e "  ${C_CYAN}0)${C_RESET}  ${C_DIM}Sair${C_RESET}"
  echo ""

  while true; do
    read_tty "  ${C_BOLD}Escolha [0-1]:${C_RESET} " OPCAO
    case "$OPCAO" in
      1) menu_principal; return ;;
      0) echo -e "\n  ${C_DIM}Saindo...${C_RESET}\n"; exit 0 ;;
      *) echo -e "  ${C_YELLOW}Opção inválida. Digite 0 ou 1.${C_RESET}" ;;
    esac
  done
}

menu_principal() {
  print_header

  echo -e "  ${C_BOLD}O que você deseja fazer?${C_RESET}"
  echo ""
  echo -e "  ${C_DIM}── Cenário sem ALB ────────────────────────────${C_RESET}"
  echo -e "  ${C_CYAN}1)${C_RESET}  ${C_BOLD}Deploy${C_RESET}         — Build, push e deploy (sem ALB)"
  echo -e "  ${C_CYAN}2)${C_RESET}  ${C_BOLD}Rollback${C_RESET}       — Reverter para revisão anterior (sem ALB)"
  echo -e "  ${C_CYAN}3)${C_RESET}  ${C_BOLD}Status${C_RESET}         — Status do serviço ECS (sem ALB)"
  echo ""
  echo -e "  ${C_DIM}── Cenário com ALB ────────────────────────────${C_RESET}"
  echo -e "  ${C_CYAN}4)${C_RESET}  ${C_BOLD}Deploy  ALB${C_RESET}    — Build, push e deploy (com ALB)"
  echo -e "  ${C_CYAN}5)${C_RESET}  ${C_BOLD}Rollback ALB${C_RESET}   — Reverter para revisão anterior (com ALB)"
  echo -e "  ${C_CYAN}6)${C_RESET}  ${C_BOLD}Status  ALB${C_RESET}    — Status do serviço ECS + ALB"
  echo ""
  echo -e "  ${C_CYAN}0)${C_RESET}  ${C_DIM}Sair${C_RESET}"
  echo ""
  echo -e "  ${C_DIM}──────────────────────────────────────────────${C_RESET}"

  while true; do
    echo ""
    read_tty "  ${C_BOLD}Escolha uma opção [0-6]:${C_RESET} " OPCAO
    case "$OPCAO" in
      1) cmd_deploy;        menu_pos_acao; return ;;
      2) cmd_rollback;      menu_pos_acao; return ;;
      3) cmd_status;        menu_pos_acao; return ;;
      4) cmd_deploy_alb;    menu_pos_acao; return ;;
      5) cmd_rollback_alb;  menu_pos_acao; return ;;
      6) cmd_status_alb;    menu_pos_acao; return ;;
      0) echo -e "\n  ${C_DIM}Saindo...${C_RESET}\n"; exit 0 ;;
      *) echo -e "  ${C_YELLOW}Opção inválida. Digite um número entre 0 e 6.${C_RESET}" ;;
    esac
  done
}

# ─────────────────────────────────────────────
# STATUS — ALB
# ─────────────────────────────────────────────
cmd_status_alb() {
  echo ""
  echo -e "  ${C_BOLD}${C_CYAN}── Status do Serviço ECS (com ALB) ────────────${C_RESET}"
  echo ""

  SERVICE_INFO=$(aws ecs describe-services \
    --region "$AWS_REGION" \
    --cluster "$ECS_CLUSTER_ALB" \
    --services "$ECS_SERVICE_ALB" \
    --query "services[0].[status, runningCount, desiredCount, taskDefinition, deployments[0].rolloutState]" \
    --output json)

  echo "$SERVICE_INFO" | python3 -c "
import json, sys
data = json.load(sys.stdin)
status        = data[0]
running       = data[1]
desired       = data[2]
task_def      = data[3].split('/')[-1] if data[3] else 'N/A'
rollout_state = data[4] if data[4] else 'N/A'

cor_status = '\033[1;32m' if status == 'ACTIVE' else '\033[1;33m'
cor_tasks  = '\033[1;32m' if running == desired else '\033[1;33m'
reset = '\033[0m'

print(f'  Serviço:         {cor_status}{status}{reset}')
print(f'  Tasks:           {cor_tasks}{running}/{desired} em execução{reset}')
print(f'  Task Definition: {task_def}')
print(f'  Rollout State:   {rollout_state}')
"
  echo ""
  echo -e "  ${C_DIM}ALB:${C_RESET}  http://$ALB_DNS"
  echo ""
}

# ─────────────────────────────────────────────
# DEPLOY — ALB
# ─────────────────────────────────────────────
cmd_deploy_alb() {
  echo ""
  echo -e "  ${C_BOLD}${C_CYAN}── Deploy (com ALB) ───────────────────────────${C_RESET}"
  echo ""

  if ! git -C "$PROJECT_DIR" rev-parse --is-inside-work-tree &>/dev/null; then
    error "Diretório não é um repositório Git: $PROJECT_DIR"
  fi
  COMMIT_HASH=$(git -C "$PROJECT_DIR" rev-parse --short HEAD)
  COMMIT_MSG=$(git -C "$PROJECT_DIR" log -1 --pretty=format:"%s" 2>/dev/null || echo "N/A")
  IMAGE_URI="$ECR_URI:$COMMIT_HASH"

  echo -e "  ${C_DIM}Commit:${C_RESET}  ${C_BOLD}$COMMIT_HASH${C_RESET} — $COMMIT_MSG"
  echo -e "  ${C_DIM}Imagem:${C_RESET}  $IMAGE_URI"
  echo -e "  ${C_DIM}Cluster:${C_RESET} $ECS_CLUSTER_ALB  |  ${C_DIM}Serviço:${C_RESET} $ECS_SERVICE_ALB"
  echo ""
  echo -e "  ${C_YELLOW}⚠  Confirma o deploy desta imagem para o ECS (com ALB)?${C_RESET}"
  echo ""
  echo -e "  ${C_CYAN}1)${C_RESET}  Sim, executar deploy"
  echo -e "  ${C_CYAN}0)${C_RESET}  Cancelar"
  echo ""

  while true; do
    read_tty "  ${C_BOLD}Escolha [0-1]:${C_RESET} " CONF
    case "$CONF" in
      1) break ;;
      0) warn "Deploy cancelado."; return ;;
      *) echo -e "  ${C_YELLOW}Opção inválida. Digite 0 ou 1.${C_RESET}" ;;
    esac
  done

  echo ""
  log "Iniciando deploy ALB — commit: $COMMIT_HASH"

  log "Fazendo build da imagem..."
  docker build -t "$IMAGE_URI" "$PROJECT_DIR"
  success "Build concluído."

  log "Autenticando no ECR..."
  aws ecr get-login-password --region "$AWS_REGION" \
    | docker login --username AWS --password-stdin "$ECR_URI"
  success "Autenticado no ECR."

  log "Fazendo push da imagem para o ECR..."
  docker push "$IMAGE_URI"
  success "Push concluído: $IMAGE_URI"

  log "Adicionando tag latest..."
  IMAGE_LATEST="$ECR_URI:latest"
  docker tag "$IMAGE_URI" "$IMAGE_LATEST"
  docker push "$IMAGE_LATEST"
  success "Push concluído: $IMAGE_LATEST"

  log "Buscando configuração atual da task definition..."
  CURRENT_TASK_DEF=$(aws ecs describe-task-definition \
    --region "$AWS_REGION" \
    --task-definition "$TASK_DEF_FAMILY_ALB" \
    --query "taskDefinition" \
    --output json)

  NEW_TASK_DEF=$(echo "$CURRENT_TASK_DEF" | python3 -c "
import json, sys
td = json.load(sys.stdin)
for c in td['containerDefinitions']:
    c['image'] = '$IMAGE_URI'
for field in ['taskDefinitionArn','revision','status','requiresAttributes',
              'compatibilities','registeredAt','registeredBy','deregisteredAt']:
    td.pop(field, None)
print(json.dumps(td))
")

  log "Registrando nova revisão da task definition..."
  NEW_REVISION=$(aws ecs register-task-definition \
    --region "$AWS_REGION" \
    --cli-input-json "$NEW_TASK_DEF" \
    --query "taskDefinition.revision" \
    --output text)
  success "Nova revisão registrada: $TASK_DEF_FAMILY_ALB:$NEW_REVISION"

  log "Atualizando serviço ECS para $TASK_DEF_FAMILY_ALB:$NEW_REVISION..."
  aws ecs update-service \
    --region "$AWS_REGION" \
    --cluster "$ECS_CLUSTER_ALB" \
    --service "$ECS_SERVICE_ALB" \
    --task-definition "$TASK_DEF_FAMILY_ALB:$NEW_REVISION" \
    --output text --query "service.serviceName" > /dev/null
  success "Serviço atualizado."

  log "Aguardando o serviço estabilizar (pode levar alguns minutos)..."
  aws ecs wait services-stable \
    --region "$AWS_REGION" \
    --cluster "$ECS_CLUSTER_ALB" \
    --services "$ECS_SERVICE_ALB"
  success "Serviço estável."

  echo ""
  echo -e "  ${C_GREEN}${C_BOLD}╔═══════════════════════════════════════════════╗${C_RESET}"
  echo -e "  ${C_GREEN}${C_BOLD}║      ✅  Deploy ALB finalizado com sucesso!    ║${C_RESET}"
  echo -e "  ${C_GREEN}${C_BOLD}╠═══════════════════════════════════════════════╣${C_RESET}"
  echo -e "  ${C_GREEN}${C_BOLD}║${C_RESET}  Imagem:    ${C_BOLD}$COMMIT_HASH${C_RESET}"
  echo -e "  ${C_GREEN}${C_BOLD}║${C_RESET}  Revisão:   ${C_BOLD}$TASK_DEF_FAMILY_ALB:$NEW_REVISION${C_RESET}"
  echo -e "  ${C_GREEN}${C_BOLD}║${C_RESET}  URL:       ${C_BOLD}http://$ALB_DNS${C_RESET}"
  echo -e "  ${C_GREEN}${C_BOLD}╚═══════════════════════════════════════════════╝${C_RESET}"
  echo ""
}

# ─────────────────────────────────────────────
# ROLLBACK — ALB
# ─────────────────────────────────────────────
cmd_rollback_alb() {
  echo ""
  echo -e "  ${C_BOLD}${C_CYAN}── Rollback (com ALB) ─────────────────────────${C_RESET}"
  echo ""
  log "Buscando revisões disponíveis de $TASK_DEF_FAMILY_ALB..."

  REVISIONS=$(aws ecs list-task-definitions \
    --region "$AWS_REGION" \
    --family-prefix "$TASK_DEF_FAMILY_ALB" \
    --status ACTIVE \
    --sort DESC \
    --query "taskDefinitionArns[]" \
    --output json)

  REVISION_COUNT=$(echo "$REVISIONS" | python3 -c "import json,sys; print(len(json.load(sys.stdin)))")
  if [ "$REVISION_COUNT" -eq 0 ]; then
    error "Nenhuma revisão encontrada para $TASK_DEF_FAMILY_ALB."
  fi

  CURRENT_REVISION=$(aws ecs describe-services \
    --region "$AWS_REGION" \
    --cluster "$ECS_CLUSTER_ALB" \
    --services "$ECS_SERVICE_ALB" \
    --query "services[0].taskDefinition" \
    --output text | grep -oE '[0-9]+$')

  echo ""
  echo -e "  ${C_BOLD}Revisões disponíveis para ${C_CYAN}$TASK_DEF_FAMILY_ALB${C_RESET}${C_BOLD}:${C_RESET}"
  echo ""
  printf "  ${C_DIM}%-5s  %-10s  %-22s  %-35s  %s${C_RESET}\n" \
    "Nº" "REVISÃO" "DATA/HORA (UTC)" "IMAGEM (TAG)" "STATUS"
  echo -e "  ${C_DIM}────  ──────────  ──────────────────────  ───────────────────────────────────  ──────────${C_RESET}"

  echo "$REVISIONS" | python3 -c "
import json, sys, subprocess

arns = json.load(sys.stdin)
current = '$CURRENT_REVISION'
entries = []

for i, arn in enumerate(arns, start=1):
    result = subprocess.run(
        ['aws', 'ecs', 'describe-task-definition',
         '--region', '$AWS_REGION',
         '--task-definition', arn,
         '--query', 'taskDefinition.[revision, registeredAt, containerDefinitions[0].image]',
         '--output', 'json'],
        capture_output=True, text=True
    )
    data = json.loads(result.stdout)
    revision_num  = str(data[0])
    registered_at = data[1][:19].replace('T', ' ') if data[1] else 'N/A'
    image_tag     = data[2].split(':')[-1] if data[2] and ':' in data[2] else (data[2] or 'N/A')
    is_current    = revision_num == current

    cor_linha = '\033[1;32m' if is_current else '\033[0m'
    status    = '<-- EM USO' if is_current else ''
    reset     = '\033[0m'

    print(f'  {cor_linha}{i:<5} {revision_num:<10}  {registered_at:<22}  {image_tag:<35}  {status}{reset}')
    entries.append(revision_num)

import json as j2
with open('/tmp/bia_rollback_alb_map.json','w') as f:
    j2.dump(entries, f)
"

  echo ""
  warn "Revisão atualmente em uso: $CURRENT_REVISION"
  echo ""
  echo -e "  ${C_DIM}Digite o número da linha (ex: 1) ou o número da revisão. ENTER para cancelar.${C_RESET}"
  echo ""

  while true; do
    read_tty "  ${C_BOLD}Revisão para rollback:${C_RESET} " CHOSEN

    if [ -z "$CHOSEN" ]; then
      warn "Rollback cancelado."
      return
    fi

    RESOLVED=$(python3 -c "
import json
try:
    entries = json.load(open('/tmp/bia_rollback_alb_map.json'))
    chosen = '$CHOSEN'
    if chosen.isdigit() and 1 <= int(chosen) <= len(entries):
        idx = int(chosen) - 1
        if chosen not in entries:
            print(entries[idx])
        else:
            print(chosen)
    elif chosen in entries:
        print(chosen)
    else:
        print('INVALID')
except Exception:
    print('INVALID')
" 2>/dev/null)

    if [ "$RESOLVED" = "INVALID" ]; then
      echo -e "  ${C_YELLOW}Entrada inválida. Use o número da linha ou o número da revisão.${C_RESET}"
      continue
    fi
    break
  done

  if [ "$RESOLVED" = "$CURRENT_REVISION" ]; then
    warn "Revisão $RESOLVED já está em uso. Nenhuma alteração feita."
    return
  fi

  echo ""
  echo -e "  ${C_YELLOW}⚠  Confirma o rollback para ${C_BOLD}$TASK_DEF_FAMILY_ALB:$RESOLVED${C_RESET}${C_YELLOW}?${C_RESET}"
  echo ""
  echo -e "  ${C_CYAN}1)${C_RESET}  Sim, executar rollback"
  echo -e "  ${C_CYAN}0)${C_RESET}  Cancelar"
  echo ""

  while true; do
    read_tty "  ${C_BOLD}Escolha [0-1]:${C_RESET} " CONF
    case "$CONF" in
      1) break ;;
      0) warn "Rollback cancelado."; return ;;
      *) echo -e "  ${C_YELLOW}Opção inválida.${C_RESET}" ;;
    esac
  done

  log "Fazendo rollback para $TASK_DEF_FAMILY_ALB:$RESOLVED..."
  aws ecs update-service \
    --region "$AWS_REGION" \
    --cluster "$ECS_CLUSTER_ALB" \
    --service "$ECS_SERVICE_ALB" \
    --task-definition "$TASK_DEF_FAMILY_ALB:$RESOLVED" \
    --output text --query "service.serviceName" > /dev/null
  success "Serviço atualizado para $TASK_DEF_FAMILY_ALB:$RESOLVED."

  log "Aguardando o serviço estabilizar (pode levar alguns minutos)..."
  aws ecs wait services-stable \
    --region "$AWS_REGION" \
    --cluster "$ECS_CLUSTER_ALB" \
    --services "$ECS_SERVICE_ALB"
  success "Serviço estável."

  echo ""
  echo -e "  ${C_GREEN}${C_BOLD}╔═══════════════════════════════════════════════╗${C_RESET}"
  echo -e "  ${C_GREEN}${C_BOLD}║     ✅  Rollback ALB concluído com sucesso!    ║${C_RESET}"
  echo -e "  ${C_GREEN}${C_BOLD}╠═══════════════════════════════════════════════╣${C_RESET}"
  echo -e "  ${C_GREEN}${C_BOLD}║${C_RESET}  Revisão ativa:  ${C_BOLD}$TASK_DEF_FAMILY_ALB:$RESOLVED${C_RESET}"
  echo -e "  ${C_GREEN}${C_BOLD}║${C_RESET}  URL:            ${C_BOLD}http://$ALB_DNS${C_RESET}"
  echo -e "  ${C_GREEN}${C_BOLD}╚═══════════════════════════════════════════════╝${C_RESET}"
  echo ""
}

# ─────────────────────────────────────────────
# Ponto de entrada
# ─────────────────────────────────────────────
case "${1:-}" in
  deploy)        print_header "$ECS_CLUSTER"     "$ECS_SERVICE";     cmd_deploy       ;;
  rollback)      print_header "$ECS_CLUSTER"     "$ECS_SERVICE";     cmd_rollback     ;;
  status)        print_header "$ECS_CLUSTER"     "$ECS_SERVICE";     cmd_status       ;;
  deploy-alb)    print_header "$ECS_CLUSTER_ALB" "$ECS_SERVICE_ALB"; cmd_deploy_alb   ;;
  rollback-alb)  print_header "$ECS_CLUSTER_ALB" "$ECS_SERVICE_ALB"; cmd_rollback_alb ;;
  status-alb)    print_header "$ECS_CLUSTER_ALB" "$ECS_SERVICE_ALB"; cmd_status_alb   ;;
  "")            menu_principal ;;
  *)
    echo ""
    echo -e "  ${C_RED}Comando desconhecido: ${1}${C_RESET}"
    echo ""
    echo -e "  Uso: ${C_BOLD}$0 [comando]${C_RESET}"
    echo ""
    echo -e "  ${C_DIM}── Sem ALB ──────────────────────────────────${C_RESET}"
    echo -e "    deploy       Build, push e deploy (sem ALB)"
    echo -e "    rollback     Reverter para revisão anterior (sem ALB)"
    echo -e "    status       Status do serviço ECS (sem ALB)"
    echo ""
    echo -e "  ${C_DIM}── Com ALB ──────────────────────────────────${C_RESET}"
    echo -e "    deploy-alb   Build, push e deploy (com ALB)"
    echo -e "    rollback-alb Reverter para revisão anterior (com ALB)"
    echo -e "    status-alb   Status do serviço ECS + ALB"
    echo ""
    echo -e "  Ou execute ${C_BOLD}$0${C_RESET} sem argumentos para o menu interativo."
    echo ""
    exit 1
    ;;
esac
