/** This is an automatically generated class by FairyGUI. Please do not modify it. **/

using FairyGUI;
using FairyGUI.Utils;

namespace TestBag
{
	public partial class UI_Bag_WindowFrame : GLabel
	{
		public GImage m_n0;
		public GGraph m_dragArea;
		public GTextField m_title;
		public UI_Bag_CloseButton m_closeButton;

		public const string URL = "ui://rbw1tv9tdwwc3";

		public static UI_Bag_WindowFrame CreateInstance()
		{
			return (UI_Bag_WindowFrame)UIPackage.CreateObject("TestBag","WindowFrame");
		}

		public UI_Bag_WindowFrame()
		{
		}

		public override void ConstructFromXML(XML xml)
		{
			base.ConstructFromXML(xml);

			m_n0 = (GImage)this.GetChild("n0");
			m_dragArea = (GGraph)this.GetChild("dragArea");
			m_title = (GTextField)this.GetChild("title");
			m_closeButton = (UI_Bag_CloseButton)this.GetChild("closeButton");
		}
	}
}