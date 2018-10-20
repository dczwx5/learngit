//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

package kof.ui.components {

import morn.core.components.SpriteBlitFrameClip;
import morn.core.components.View;

public function registerCustomMornUIComps() : void {
    View.registerComponent( "KOFLabel", TestLabel );
    View.registerComponent( "KOFResLabel", KOFResLabel );
    View.registerComponent( "KOFProgressBar", KOFProgressBar );
    View.registerComponent( "ProgressBar", KOFProgressBar );
    View.registerComponent( "KOFProgressBarII", KOFProgressBarII );
    View.registerComponent( "KOFHSlider", KOFHSlider );
    View.registerComponent( "BaseModuleView", BaseModuleView );
    View.registerComponent( "MaskBox", MaskBox );
    View.registerComponent( "KOFButton", KOFButton );
    View.registerComponent( "KOFTab", KOFTab );
    View.registerComponent( "KOFNum", KOFNum );
    View.registerComponent( "KOFMenu", KOFMenu );
    View.registerComponent( "SpriteBlitFrameClip", SpriteBlitFrameClip );
    View.registerComponent( "KOFComboBox", KOFComboBox );
    View.registerComponent( "KOFVList", KOFVList );
    View.registerComponent( "KOFFrameClipProgressBar", KOFFrameClipProgressBar );
    View.registerComponent( "BossComingView", BossComingView );
    View.registerComponent( "KOFLinkButton", KOFLinkButton );
    View.registerComponent( "KOFPanel", KOFPanel );
    View.registerComponent( "ButtonGroup", ButtonGroup );
    View.registerComponent( "KOFList", KOFList );
    View.registerComponent( "KOFDialog", KOFDialog );
}
}