import React, { useState, useEffect } from 'react';
import { Link } from 'react-router-dom';

const VersionInfo = () => {
  const [apiStatus, setApiStatus] = useState('checking'); // 'checking', 'online', 'offline'

  const getApiUrl = () => {
    // Se estiver definido no ambiente (Docker/Produção)
    if (import.meta.env.VITE_API_URL) {
      return import.meta.env.VITE_API_URL;
    }

    // Se estiver rodando no mesmo domínio (produção integrada)
    if (window.location.port === '8080') {
      return window.location.origin;
    }

    // Desenvolvimento local - inferir porta 8080
    return 'http://localhost:8080';
  };

  const checkApiHealth = async () => {
    setApiStatus('checking');
    try {
      const apiUrl = getApiUrl();
      const controller = new AbortController();
      const timeoutId = setTimeout(() => controller.abort(), 5000); // 5s timeout

      const response = await fetch(`${apiUrl}/api/versao`, {
        signal: controller.signal,
        method: 'GET',
        cache: 'no-cache'
      });

      clearTimeout(timeoutId);

      setApiStatus(response.ok ? 'online' : 'offline');
    } catch (error) {
      console.warn('API Health Check falhou:', error.message);
      setApiStatus('offline');
    }
  };

  useEffect(() => {
    checkApiHealth();
    // Recheck a cada 30 segundos
    const interval = setInterval(checkApiHealth, 30000);
    return () => clearInterval(interval);
  }, []);

  const getStatusIcon = () => {
    switch (apiStatus) {
      case 'online': return '🟢';
      case 'offline': return '🔴';
      case 'checking': return '🟡';
      default: return '⚪';
    }
  };

  const getStatusText = () => {
    switch (apiStatus) {
      case 'online': return 'Online';
      case 'offline': return 'Offline';
      case 'checking': return 'Verificando...';
      default: return 'Desconhecido';
    }
  };

  return (
    <Link
      to="/versao"
      className="btn"
      title={`API: ${getStatusText()}`}
    >
      {getStatusIcon()} API
    </Link>
  );
};

export default VersionInfo;
