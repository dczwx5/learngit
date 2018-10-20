package morn.editor
{

import flash.display.BitmapData;
import flash.display.Sprite;
import flash.display.Stage;
import flash.events.Event;
import flash.system.ApplicationDomain;
import flash.utils.ByteArray;

/**
 * 编辑器插件基类
 *
 * @author Jeremy (jeremy@qifun.com)
 */
public class PluginBase extends Sprite
{

    /**
     * Creates a new PluginBase.
     */
    public function PluginBase()
    {
        super();
    }

    /**
     * 插件运行方法，编辑器调用接口
     */
    public function start() : void
    {
    }

    /**
     * 页面切换时调用
     */
    public function onPageChanged( event : Event ) : void
    {
    }

    /**
     * 页面保存时调用
     */
    public function onPageSaved( event : Event ) : void
    {
    }

    /**
     * 读取文本文件
     *
     * @param path 文件的物理地址
     */
    public static function readTxt( path : String ) : String
    {
        return null;
    }

    /**
     * 写入文本文件
     *
     * @param path 文件的物理地址
     * @param value 文件的内容
     */
    public static function writeTxt( path : String, value : String ) : void
    {
    }

    /**
     * 读取二进制文件
     *
     * @param path 文件的物理地址
     */
    public static function readByte( path : String ) : ByteArray
    {
        return null;
    }

    /**
     * 写入二进制文件
     *
     * @param path 文件的物理地址
     * @param bytes 文件的内容
     */
    public static function writeByte( path : String, bytes : ByteArray ) : void
    {
    }

    /**
     * 编辑器目录物理地址
     */
    public static function get appPath() : String
    {
        return "";
    }

    /**
     * 项目目录物理地址
     */
    public static function get workPath() : String
    {
        return "";
    }

    /**
     * 插件目录物理地址
     */
    public static function get pluginPath() : String
    {
        return "";
    }

    /**
     * 获取绝对路径
     */
    public static function getPath( basePath : String, relativePath : String ) : String
    {
        return "";
    }

    public static function getRelativePath( basePath : String, targetPath : String ) : String
    {
        return "";
    }

    public static function getFileList( path : String ) : Array
    {
        return [];
    }

    public static function loadByPath( path : String, complete : Function = null ) : void
    {

    }

    public static function loadByContent( bytes : ByteArray, complete : Function = null ) : void
    {

    }

    //--------------------------------------------------------------------------
    // 界面操作
    //--------------------------------------------------------------------------

    public static function get builderStage() : Stage
    {
        return null;
    }

    public static function get builderMain() : Sprite
    {
        return null;
    }

    public static function get pluginDomain() : ApplicationDomain
    {
        return null;
    }

    public static function hasClass( name : String ) : Boolean
    {
        return pluginDomain.hasDefinition( name );
    }

    public static function getClass( name : String ) : Class
    {
        if ( hasClass( name ) )
        {
            return pluginDomain.getDefinition( name ) as Class;
        }
        log( "Miss Asset:" + name );
        return null;
    }

    public static function getAsset( name : String )
    {
        var bmdClass : Class = getClass( name );
        if ( bmdClass == null )
        {
            return null;
        }
        return new bmdClass();
    }

    public static function getBitmapData( name : String ) : BitmapData
    {
        var bmdClass : Class = getClass( name );
        if ( bmdClass == null )
        {
            return null;
        }
        return new bmdClass( 1, 1 );
    }

    public static function showWaiting( title : String, msg : String ) : void
    {

    }

    public static function closeWaiting() : void
    {

    }

    public static function alert( title : String, text : String ) : void
    {

    }

    public static function confirm( title : String, text : String, closeHandler : Function = null ) : void
    {

    }

    public static function log( value : String ) : void
    {
        trace( value );

    }

    public static function get viewXml() : XML
    {
        return null;
    }

    public static function get viewPath() : String
    {
        return null;
    }

    public static function changeViewXml( xml : XML, refresh : Boolean = false ) : void
    {

    }

    public static function get selectedXmls() : Array
    {
        return null;
    }

    public static function getCompById( compId : int ) : Sprite
    {
        return null;
    }

    public static function openPage( path : String ) : void
    {

    }

    public static function exeCmds( cmds : Array, cmdComplete : Function = null, cmdProgress : Function = null, cmdError : Function = null ) : void
    {

    }

}
}

