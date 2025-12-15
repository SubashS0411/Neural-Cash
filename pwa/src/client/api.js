import axios from 'axios';

const client = axios.create({ baseURL: '/api/v1' });

export const api = {
  setToken(token) {
    client.defaults.headers.common.Authorization = token ? `Bearer ${token}` : undefined;
  },
  get: (url, config) => client.get(url, config).then((r) => r.data),
  post: (url, body, config) => client.post(url, body, config).then((r) => r.data),
};
