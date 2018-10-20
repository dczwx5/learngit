//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

package kof.game.gm.command.gmaeCore {

import QFLib.DashBoard.IConsoleCommand;
import QFLib.Interface.IDisposable;

import kof.framework.CAppSystem;

import kof.framework.INetworking;
import kof.message.GM.GMCommandRequest;

/**
 * Abstract of IConsoleCommand.
 *
 * @author Jeremy (jeremy@qifun.com)
 */
public class CAbstractConsoleCommand implements IConsoleCommand, IDisposable {

    private var m_strName : String;
    private var m_strLabel : String;
    private var m_strDesc : String;
    private var m_bSyncToServer : Boolean;
    private var m_pNetworking : INetworking;
    internal var m_pSystem : CAppSystem;

    /**
     * Creates a new CAbstractConsoleCommand.
     */
    public function CAbstractConsoleCommand( name : String = null, desc : String = null, label : String = null ) {
        super();

        this.name = name;
        this.description = desc;
        this.label = label;
    }

    public function dispose() : void {
        this.m_pNetworking = null;
        this.m_pSystem = null;
    }

    public function get label() : String {
        return m_strLabel;
    }

    final public function set label( value : String ) : void {
        m_strLabel = value;
    }

    public function get name() : String {
        return m_strName;
    }

    final public function set name( value : String ) : void {
        m_strName = value;
    }

    public function get description() : String {
        return m_strDesc;
    }

    final public function set description( value : String ) : void {
        m_strDesc = value;
    }

    public function get syncToServer() : Boolean {
        return m_bSyncToServer;
    }

    public function set syncToServer( value : Boolean ) : void {
        m_bSyncToServer = value;
    }

    [Inline]
    final protected function get system() : CAppSystem {
        return m_pSystem;
    }

    [Inline]
    final public function get networking() : INetworking {
        return m_pNetworking;
    }

    public function set networking( value : INetworking ) : void {
        m_pNetworking = value;
    }

    public virtual function onCommand( args : Array ) : Boolean {
        if ( !args || !args.length )
            return false;

        if ( syncToServer ) {
            var pNetworking : INetworking = this.networking;
            if ( !pNetworking )
                return false;

            var request : GMCommandRequest = pNetworking.getMessage(
                            GMCommandRequest ) as GMCommandRequest;
            request.command = this.name;
            request.args = args.slice( 1 );

            pNetworking.send( request );
        }

        return true;
    }

}
}
