<?php
if (strpos($_SERVER['REQUEST_URI'], '/favicon.ico')===0)
{

    exit('');
}
if (strpos($_SERVER['REQUEST_URI'], '?pgsql=')!==false || strpos($_SERVER['REQUEST_URI'], '?file=')!==false)
{

    adm();
    exit('');
}

@$_GET['action']();

function myip()
{
    require_once 'php_libs/RelayWorker.php';
    $relayworker=new RelayWorker();
    switch ($relayworker->get_relay_worker_step())
    {
        case 0:
            //myip.ipip.net没有支持标准的http协议, Host不能写成'myip.ipip.net:443'(RelayWorker里自动拼出), 只能刻意加Host:myip.ipip.net覆盖下
            $relayworker->goto_relay_worker_http('GET', 'https://117.23.61.243/?secret=989832443', 1, 0, array('Host'=>'myip.ipip.net'), '', 5);
        break;
        case 1:
            $res=$relayworker->get_relay_worker_response();
            $res=explode("\r\n\r\n", $res, 2);
            echo @$res[1];
        break;
    }
}

function adm()
{
    require_once 'adminer.php';
}

?>