import axios from 'axios';

const apiClient = axios.create({
  baseURL: '/api',
  timeout: 10000,
  headers: {
    'Content-Type': 'application/json',
  },
});

apiClient.interceptors.response.use(
  (response) => response.data,
  (error) => {
    const message = error.response?.data?.detail || error.response?.data?.message || '请求失败';
    console.error('API Error:', message);
    return Promise.reject(error);
  }
);

export default apiClient;
