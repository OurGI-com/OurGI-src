<?php

/**
 *  兼容php7版本的apc
 */
if (!function_exists("apc_fetch"))
{
    function apc_fetch( $key ,  &$success=false )
    {
        return apcu_fetch($key, $success);
    }
}


if (!function_exists("apc_store"))
{
    function apc_store( $values , $unused = NULL , $ttl = 0  )
    {
        return apcu_store($values , $unused , $ttl);
    }
}


if (!function_exists("apc_delete"))
{
    function apc_delete( $key )
    {
        return apcu_delete($key);
    }
}

