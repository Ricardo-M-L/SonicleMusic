/**
 * 配置axios
 * @param {AxiosRequestConfig}config
 * @returns {AxiosPromise<any>}
 */
import axios, { AxiosRequestConfig, AxiosPromise, AxiosResponse } from 'axios'
import { BASE_URL, TIMEOUT } from './constant'

function request(config: AxiosRequestConfig): AxiosPromise<any> {
  const instance = axios.create({
    baseURL: BASE_URL,
    timeout: TIMEOUT,
    withCredentials: true
  })

  // 请求拦截
  instance.interceptors.request.use(
    (config: AxiosRequestConfig) => {
      return config
    },
    (error: any) => {
      console.error('请求错误:', error)
      return Promise.reject(error)
    }
  )

  // 响应拦截
  instance.interceptors.response.use(
    (response: AxiosResponse<any>) => {
      return response.data
    },
    (error: any) => {
      // 处理HTTP错误状态码
      if (error.response) {
        const status = error.response.status
        switch (status) {
          case 400:
            console.error('请求参数错误')
            break
          case 401:
            console.error('未授权，请登录')
            break
          case 403:
            console.error('拒绝访问')
            break
          case 404:
            console.error('请求资源不存在')
            break
          case 500:
            console.error('服务器内部错误')
            break
          default:
            console.error(`请求错误: ${status}`)
        }
      } else if (error.request) {
        console.error('网络错误，请检查网络连接')
      } else {
        console.error('请求配置错误:', error.message)
      }
      return Promise.reject(error)
    }
  )

  return instance(config)
}

export default request
