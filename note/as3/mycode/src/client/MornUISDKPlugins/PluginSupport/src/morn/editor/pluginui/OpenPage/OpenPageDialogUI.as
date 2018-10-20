/**Created by the Morn,do not modify.*/
package morn.editor.pluginui.OpenPage {
	import morn.core.components.*;import morn.editor.*;
	public class OpenPageDialogUI extends PluginDialog {
		public var txtFileName:TextInput = null;
		protected static var uiXML:XML =
			<PluginDialog width="450" height="72">
			  <Image skin="png.comp.bg" left="0" right="0" top="0" bottom="0" sizeGrid="4,30,4,4"/>
			  <Button skin="png.comp.btn_close" y="3" right="7" x="417" name="close"/>
			  <VBox space="15" align="left" left="10" right="10" top="5" bottom="5" x="10" y="10">
			    <HBox space="5" y="23" left="0" right="0">
			      <TextInput skin="png.comp.textinput" sizeGrid="2,2,2,2" margin="1,1,1,1" var="txtFileName" selectable="true" height="25" centerY="0" restrict="0-9a-zA-Z_ " right="75" left="0"/>
			      <Button label="\(^o^)/~" skin="png.comp.button" sizeGrid="4,4,4,4" centerY="0" name="ok" right="0" width="72"/>
			    </HBox>
			    <Label text="Search Everywhere: " x="3"/>
			  </VBox>
			</PluginDialog>;
		public function OpenPageDialogUI(){}
		override protected function createChildren():void {
			super.createChildren();
			createView(uiXML);
		}
	}
}