<?php
require_once __DIR__.'/php_libs/apc_php7.php';

@$_GET['action']();

function apc_save()
{
    $post=@file_get_contents('php://input');
    if (@$_GET['key'] && apc_store($_GET['key'], $post, @$_GET['ttl']?$_GET['ttl']:60))
    {
        exit('OK');
    }
    exit('');
}

function apc_clear()
{
    if (@$_GET['keys'])
    {
        $keys=explode(',', $_GET['keys']);
        foreach ($keys as $key)
        {
            @apc_delete($key);
        }
        exit('OK');
    }
    exit('');
}

function crontab()
{
    //file_put_contents('/tmp/a.txt', $_GET['timestamp']."\r\n", FILE_APPEND);
}
