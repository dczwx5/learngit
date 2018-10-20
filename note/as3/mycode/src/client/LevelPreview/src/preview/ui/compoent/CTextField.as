/**
 * Created by auto on 2016/5/31.
 */
package preview.ui.compoent {

import flash.text.TextField;
import flash.text.TextFieldAutoSize;
import flash.text.TextFormat;

public class CTextField extends CBaseSprite {
    public function CTextField(w:int, h:int) {
        super(w, h);
        _textField = new TextField();

    }

    protected override function _onAdd() : void {
        super._onAdd();

        _textField.width = uiWidth;
        _textField.height = uiHeight;

        this.setFontFormat();

        _textField.selectable = false;
        this.addChild(_textField);

    }
    protected override function _onRemove() : void {
        super._onRemove();
        this.removeChild(_textField);
        _textField = null;
    }

    public override function setSize(w:int, h:int) : void {
        super.setSize(w, h);
        _textField.width = uiWidth;
        _textField.height = uiHeight;
    }
    public function setFontSize(size:int) : void {
        if (_fontSize == size) return ;
        _fontSize = size;
        this.setFontFormat();
    }
    public function setFontColor(color:int) : void {
        if (_fontColor == color) return ;
        _fontColor = color;
        this.setFontFormat();
    }
    public function setFontStyle(style:String) : void {
        if (_fontStyle == style) return ;
        _fontStyle = style;
        this.setFontFormat();
    }
    public function alignLeft() : void {
        _textField.autoSize = TextFieldAutoSize.LEFT;
    }
    public function alignCenter() : void {
        _textField.autoSize = TextFieldAutoSize.CENTER;
    }

    private function setFontFormat() : void  {
        var format:TextFormat = new TextFormat();
        //ormat.font = _fontStyle;
        format.color = _fontColor;
        format.size = _fontSize;
        format.underline = false;
        _textField.setTextFormat(format);
        // _textField.defaultTextFormat = format;
    }
    public function set text(v:String) : void {
        _textField.text = v;
    }
    public function get text() : String {
        return _textField.text;
    }
    public function setType(v:String) : void {
        _textField.type = v;
    }
    public function setSelectAble(v:Boolean) : void {
        _textField.selectable = v;
    }
    public function getCompoent() : TextField {
        return _textField;
    }
    private var _textField:TextField;
    private var _fontSize:int = 10;
    private var _fontColor:int = -1;
    private var _fontStyle:String = "Verdana";
}
}
