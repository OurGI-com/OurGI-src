<?php
require_once __DIR__ . "/apc_php7.php";

class RelayWorker
{
    public $data;

    function goto_relay_worker_http($method, $url, $step='', $delay=0, $custom_headers=array(), $str_data='', $total_timeout=20.5, $proxy='', $http_version='1.1')
    {
        if ($method==='TCP')
        {
            $relay_worker_fetch_request=$str_data;
            $proxy=$proxy?$proxy:$url;
        }
        else
        {
            $method=$method==='POST'?'POST':'GET';
            $http_version = "1.1";//$http_version === '1.0' ? '1.0' : '1.1';
            $url_parts=explode('/', $url, 4);
            $host_port=strpos($url_parts[2], ':')!==false?$url_parts[2]:$url_parts[2].':'.(strpos($url, 'https')===0?'443':'80');
            $uri=@$url_parts[3];
            $proxy=$proxy?$proxy:(strpos($url, 'https')===0?'':$host_port);

            $headers="{$method} /{$uri} HTTP/{$http_version}\r\n";
            @$custom_headers['Host']?'':($headers.= "Host: {$host_port}\r\n");
            @$custom_headers['Origin']?'':($headers.= "Origin: http://{$host_port}\r\n");
            isset($custom_headers['User-Agent']) ? '' : ($headers.= "User-Agent: Mozilla/5.0 (Windows NT 5.1; rv:40.0) Gecko/20100101 Firefox/40.0\r\n");
            @$custom_headers['Accept']?'':($headers.= "Accept: text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8\r\n");//google check the 3 "Accept"
            @$custom_headers['Accept-Language']?'':($headers.= "Accept-Language: en-US,en;q=0.5,en-gb;q=0.4,de-DE;q=0.3,de;q=0.1\r\n");
            isset($custom_headers['Accept-Encoding'])?'':($headers.= "Accept-Encoding: gzip, deflate\r\n");    //sometimes need set empty to refuse to receive gziped data
            if ($method==='GET')  //GET
               {//nothing to do
               }
            else if ($method==='POST')  //POST
                 {if (!@$custom_headers['Content-Type'])
                     {$headers.= "Content-Type: application/x-www-form-urlencoded\r\n";
                     }
                 }
            foreach ($custom_headers as $k=>$v)
                    {if ($k!='Content-Length' && $k!='Connection')
                        {$headers.= "{$k}: {$v}\r\n";
                        }
                    }
            $headers.= $method==='POST'?"Content-Length: " . strlen($str_data) . "\r\n":'';    //只要post必须有content length, 即使为0
            //$headers.= (@$specified_host[1]&&!@$specified_host[2]?"Proxy-":"")."Connection: close\r\n"; //rfc2616 says "connection will be closed after completion of the response", but some servers close connection immediately
            $headers.="Connection: keep-alive\r\n";    //in HTTP 1.1, keep-alive is default
            $headers.= "\r\n";
            $str_data=is_array($str_data)?http_build_query($str_data):$str_data;
            $str_data=$method==='POST'?$str_data:'';                                //GET如果传了数据过去会被当前下一个请求的第一行即使是错误Scheme, nginx的access log会看到两条请求记录
            $relay_worker_fetch_request=$headers."$str_data";
        }

        $step=$step===''?@apc_fetch('relay-worker-step-'.$_SERVER['REQUEST_ID'])+1:$step;
        apc_store('relay-worker-step-'.$_SERVER['REQUEST_ID'], $step, 300);
        apc_store('relay-worker-globals-'.$_SERVER['REQUEST_ID'], $this->data, 300);

        header("Relay-Worker-Delay: {$delay}");
    if (strpos($url, 'https')===0) {
        $str_proxy=$proxy?"|{$proxy}":'';
        header("Relay-Worker-Fetch-Host: {$host_port}{$str_proxy}");
    }else{
        header("Relay-Worker-Fetch-Host: {$proxy}");
    }
        header("Relay-Worker-Fetch-Timeout: {$total_timeout}");
        //file_put_contents('/usr/local/nginx/logs/request.txt', "$url\n{$host_port}|{$proxy}\n".$relay_worker_fetch_request, FILE_APPEND);
        exit($relay_worker_fetch_request);
    }

    function get_relay_worker_step()
    {
        $this->data=@apc_fetch('relay-worker-globals-'.$_SERVER['REQUEST_ID']);
        $relay_step=apc_fetch('relay-worker-step-'.$_SERVER['REQUEST_ID']);
        $relay_step=@$relay_step?$relay_step:0;
        //file_put_contents('/usr/local/nginx/logs/step.txt', $relay_step."\n", FILE_APPEND);
        return $relay_step;
    }

    function get_relay_worker_response()
    {
         return apc_fetch('relay-worker-response-'.$_SERVER['REQUEST_ID']);
    }

}