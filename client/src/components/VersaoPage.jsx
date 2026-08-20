import React, { useState, useEffect } from 'react';
import { Link } from 'react-router-dom';

const getApiUrl = () => {
  if (import.meta.env.VITE_API_URL) {
    return import.meta.env.VITE_API_URL;
  }
  if (window.location.port === '8080') {
    return window.location.origin;
  }
  return 'http://localhost:8080';
};

const getEnvironmentInfo = () => {
  const { protocol, hostname, port } = window.location;

  if (hostname === 'localhost' || hostname === '127.0.0.1') {
    return { type: 'local', icon: '🏠', label: 'Local', description: `${hostname}:${port}`, color: '#3b82f6' };
  }
  if (/^\d+\.\d+\.\d+\.\d+$/.test(hostname) && protocol === 'http:') {
    return { type: 'ip-http', icon: '🌐', label: 'IP Direto', description: `${hostname}${port ? ':' + port : ''}`, color: '#f59e0b' };
  }
  if (protocol === 'http:' && hostname.includes('.elb.')) {
    return { type: 'alb-http', icon: '⚖️', label: 'ALB HTTP', description: hostname, color: '#ef4444' };
  }
  if (protocol === 'https:') {
    return { type: 'domain-https', icon: '🔒', label: 'Produção', description: hostname, color: '#22c55e' };
  }
  return { type: 'other', icon: '❓', label: 'Outro', description: `${hostname}${port ? ':' + port : ''}`, color: '#6b7280' };
};

const getStatusIcon = (status) => {
  switch (status) {
    case 'online': return '🟢';
    case 'offline': return '🔴';
    case 'checking': return '🟡';
    default: return '⚪';
  }
};

const getStatusText = (status) => {
  switch (status) {
    case 'online': return 'Online';
    case 'offline': return 'Offline';
    case 'checking': return 'Verificando...';
    default: return 'Desconhecido';
  }
};

const VersaoPage = () => {
  const [apiStatus, setApiStatus] = useState('checking');
  const [apiVersion, setApiVersion] = useState(null);
  const [error, setError] = useState(null);

  const checkApiHealth = async () => {
    setApiStatus('checking');
    setError(null);

    try {
      const apiUrl = getApiUrl();
      const controller = new AbortController();
      const timeoutId = setTimeout(() => controller.abort(), 5000);

      const response = await fetch(`${apiUrl}/api/versao`, {
        signal: controller.signal,
        method: 'GET',
        cache: 'no-cache',
      });

      clearTimeout(timeoutId);

      if (response.ok) {
        const versionText = await response.text();
        setApiVersion(versionText);
        setApiStatus('online');
      } else {
        setApiVersion(null);
        setApiStatus('offline');
        setError(`HTTP ${response.status}: ${response.statusText}`);
      }
    } catch (err) {
      setApiVersion(null);
      setApiStatus('offline');
      setError(err.name === 'AbortError' ? 'Timeout: API não respondeu em 5s' : err.message);
    }
  };

  useEffect(() => {
    checkApiHealth();
  }, []);

  const apiUrl = getApiUrl();
  const env = getEnvironmentInfo();

  return (
    <div className="tasks-container">
      <div style={{ marginBottom: '1rem' }}>
        <Link to="/" className="back-button">
          ← Voltar
        </Link>
      </div>

      <div style={{ marginBottom: '1rem', display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
        <h2 style={{ margin: 0 }}>Informações da API</h2>
        <button
          className="btn"
          onClick={checkApiHealth}
          disabled={apiStatus === 'checking'}
          title="Atualizar informações"
        >
          🔄 {apiStatus === 'checking' ? 'Verificando...' : 'Atualizar'}
        </button>
      </div>

      {/* Status da API */}
      <div className="task" style={{ marginBottom: '0.75rem' }}>
        <div style={{ display: 'flex', flexDirection: 'column', gap: '0.4rem' }}>
          <div>
            <strong>Versão da API:</strong>{' '}
            {apiStatus === 'checking'
              ? 'Verificando...'
              : apiVersion
              ? apiVersion
              : '—'}
          </div>
          <div>
            <strong>Status:</strong>{' '}
            {getStatusIcon(apiStatus)} {getStatusText(apiStatus)}
          </div>
          <div>
            <strong>Ambiente:</strong>{' '}
            <span style={{ color: env.color }}>
              {env.icon} {env.label}
            </span>{' '}
            <small>({env.description})</small>
          </div>
          <div>
            <strong>URL da API:</strong>{' '}
            <code style={{ fontSize: '0.85rem' }}>{apiUrl}</code>
          </div>
        </div>
      </div>

      {/* Erro */}
      {error && apiStatus === 'offline' && (
        <div className="task" style={{ marginBottom: '0.75rem', borderLeft: '4px solid #ef4444' }}>
          <strong>⚠️ Erro ao conectar:</strong> <span style={{ color: '#ef4444' }}>{error}</span>
        </div>
      )}
    </div>
  );
};

export default VersaoPage;
