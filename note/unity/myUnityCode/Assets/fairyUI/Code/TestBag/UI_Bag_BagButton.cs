/** This is an automatically generated class by FairyGUI. Please do not modify it. **/

using FairyGUI;
using FairyGUI.Utils;

namespace TestBag
{
	public partial class UI_Bag_BagButton : GButton
	{
		public Controller m_button;
		public GImage m_n1;
		public GMovieClip m_n2;

		public const string URL = "ui://rbw1tv9tthi7c";

		public static UI_Bag_BagButton CreateInstance()
		{
			return (UI_Bag_BagButton)UIPackage.CreateObject("TestBag","BagButton");
		}

		public UI_Bag_BagButton()
		{
		}

		public override void ConstructFromXML(XML xml)
		{
			base.ConstructFromXML(xml);

			m_button = this.GetController("button");
			m_n1 = (GImage)this.GetChild("n1");
			m_n2 = (GMovieClip)this.GetChild("n2");
		}
	}
}