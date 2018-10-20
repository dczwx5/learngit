package morn.editor
{
import morn.core.components.Dialog;

public class PluginDialog extends Dialog
{
    public function PluginDialog()
    {
        super();
    }

    override public function show( closeOther : Boolean = false ) : void
    {
        Plugin.dialog.show( this, closeOther );
    }

    override public function popup( closeOther : Boolean = false ) : void
    {
        Plugin.dialog.popup( this, closeOther );
    }

    override public function close( type : String = null ) : void
    {
        Plugin.dialog.close( this );
        if ( _closeHandler != null )
        {
            _closeHandler.executeWith( [type] );
        }
    }

}
}
