import axios from "axios";
import { TokenStorage } from "./token.service";

const http = axios.create({
  baseURL: process.env.API_URL,
  headers: {
    Accept: "*/*",
    "Content-Type": "application/json",
  },
  timeout: 30000,
});

http.interceptors.request.use(
  async (config) => {
    let accessToken = TokenStorage.getToken();
    console.log("token", accessToken);
    if (accessToken) {
      config.headers["authorization"] = `Bearer ${accessToken}`;
      return config;
    }
    return config;
  },
  function (error) {
    return Promise.reject(error);
  }
);

export default http;
