//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

package kof.data {

    import QFLib.Foundation.CMap;
    import QFLib.Foundation.CProcedureManager;
    import QFLib.ResourceLoader.CJsonLoader;
    import QFLib.ResourceLoader.CPackedQsonLoader;
    import QFLib.ResourceLoader.CResource;
    import QFLib.ResourceLoader.CResourceLoaders;
    import QFLib.ResourceLoader.CSwfLoader;
    import QFLib.ResourceLoader.ELoadingPriority;

    import flash.display.DisplayObject;
    import flash.system.ApplicationDomain;

    import kof.framework.CAppStage;
    import kof.framework.CAppSystem;
    import kof.framework.IDataTable;
    import kof.framework.IDatabase;

    /**
     * 数据库AppSystem，提供数据表查询
     *
     * @author Jeremy (jeremy@qifun.com)
     */
    public class CDatabaseSystem extends CAppSystem implements IDatabase {

        /** @private */
        private const m_pManifest : Array = [
            KOFTableConstants.AUDIO,
            KOFTableConstants.PLAYER_GLOBAL,
            KOFTableConstants.PLAYER_BASIC,
            KOFTableConstants.PLAYER_DISPLAY,
            KOFTableConstants.LEVEL,
            KOFTableConstants.LEVELINFORMATION,
            KOFTableConstants.SKILL,
            KOFTableConstants.HIT,
            KOFTableConstants.SKILL_CATCH,
            KOFTableConstants.SKILL_CATCH_END,
            KOFTableConstants.TELEPORT_EFFECT,
            KOFTableConstants.MONSTER,
            KOFTableConstants.TOWN,
            KOFTableConstants.PLAYER_SKILL,
            KOFTableConstants.MONSTER_SKILL,
            KOFTableConstants.MOTION,
            KOFTableConstants.MAP_OBJECT,
            KOFTableConstants.MAP_OBJECT_SKILL,
            KOFTableConstants.NPC,
            KOFTableConstants.AI,
            KOFTableConstants.Chain,
            KOFTableConstants.ChainCondition,
            KOFTableConstants.ChainKeyCondition,
            KOFTableConstants.ChainPropertyStatus,
            KOFTableConstants.SKILLRUSH,
            KOFTableConstants.ButtonMapping,
            KOFTableConstants.LEVEL_UI_TXT,
            KOFTableConstants.CAMP_REFS,
            KOFTableConstants.GAME_PROMPT,

            KOFTableConstants.AERO,
            KOFTableConstants.AERO_ABSORBER,
            KOFTableConstants.EMITTER,
            KOFTableConstants.DAMAGE,
            KOFTableConstants.HITSHAKE,
            KOFTableConstants.SUMMONER,

            KOFTableConstants.ITEM,
            KOFTableConstants.ItemSequence,

            KOFTableConstants.DIALOGUE,
            KOFTableConstants.INSTANCE,

            KOFTableConstants.PLAYER_NAME_1,
            KOFTableConstants.PLAYER_NAME_2,
            KOFTableConstants.PLAYER_NAME_3,
            KOFTableConstants.TEAM_ICON,

            KOFTableConstants.VIP_LEVEL,
            KOFTableConstants.VIPPRIVILEGE,
            KOFTableConstants.CURRENCY,
            KOFTableConstants.CURRENCY_GOLD_CONTYPE,
            KOFTableConstants.CURRENCY_VIT_CONTYPE,
            KOFTableConstants.TEAM_LEVEL,
            KOFTableConstants.MODIFY_NAME_COST,

            KOFTableConstants.PLAYER_LINES,
            KOFTableConstants.PLAYER_CONSTANT,
            KOFTableConstants.TEAM_COEFFICIENT,

            KOFTableConstants.ROLE_SELECT,
            KOFTableConstants.MAIN_VIEW,
            KOFTableConstants.SYSTEM_IDS,
            KOFTableConstants.INSTANCE_DIALOG,
            KOFTableConstants.INSTANCE_EXIT,
            KOFTableConstants.INSTANCE_CHAPTER,
            KOFTableConstants.INSTANCE_CONTENT,
            KOFTableConstants.INSTANCE_TXT,
            KOFTableConstants.INSTANCE_CONSTANTS,
            KOFTableConstants.NUMERIC_TEMPLATE,
            KOFTableConstants.INSTANCE_TYPE,
            KOFTableConstants.MONSTER_PROPERTY,

            KOFTableConstants.HERO_TRAIN_QUALITY_LEVEL,
            KOFTableConstants.HERO_TRAIN_QUALITY,
            KOFTableConstants.HERO_TRAIN_LEVEL,
            KOFTableConstants.HERO_TRAIN_STAR,

            KOFTableConstants.EQUIP_BASE,
            KOFTableConstants.EquipUpgrade,
            KOFTableConstants.EquipUpQuality,
            KOFTableConstants.EquipAwakenTemplate,
            KOFTableConstants.EquipAwaken,
            KOFTableConstants.EQUIP_QUALITY_LEVEL,

            KOFTableConstants.DROP_PACKAGE,
            KOFTableConstants.EMBATTLE,
            KOFTableConstants.TASK,

            KOFTableConstants.PLOT_TASK,
            KOFTableConstants.BUFF,
            KOFTableConstants.BUFF_EMITTER,
            KOFTableConstants.SCREEN_EFFECT,

            KOFTableConstants.MAIL_SYSTEM,
            KOFTableConstants.TASK_ACTIVE,
            KOFTableConstants.CHAT_EMOTICON_SYSTEM,
            KOFTableConstants.CHAT_EMOTICON_SHOP,
            KOFTableConstants.CHAT_EMOTICON_SHOP_CHILD,
            KOFTableConstants.HIT_CRITERIA,

            KOFTableConstants.PEAK_GAME_LEVEL,
            KOFTableConstants.PEAK_GAME_REWARD,
            KOFTableConstants.PEAK_GAME_CONSTANT,
            KOFTableConstants.FAIR_PEAK_GAME_LEVEL,
            KOFTableConstants.FAIR_PEAK_GAME_REWARD,
            KOFTableConstants.FAIR_PEAK_GAME_CONSTANT,

            KOFTableConstants.ACTIVE_SKILL_UP,
            KOFTableConstants.PASSIVE_SKILL_UP,
            KOFTableConstants.SKILL_UP_CONSUME,
            KOFTableConstants.SKILL_POSITION_RATE,
            KOFTableConstants.SKILL_QUALITY_RATE,
            KOFTableConstants.HEALING,
            KOFTableConstants.SKILL_EMITTER_CONSUME,
            KOFTableConstants.BREACH_LV_CONST,

            KOFTableConstants.MARQUEE_MSG,
            KOFTableConstants.PASSIVE_SKILL_PRO,
            KOFTableConstants.TALENT_SOUL_POINT,
            KOFTableConstants.TALENT_CONSTANT,
            KOFTableConstants.ARTIFACT,
            KOFTableConstants.DESKTIPS,
            KOFTableConstants.TEACHINGCONTENT,
            KOFTableConstants.TEACHINGGOAL,
            KOFTableConstants.PRACTICE,
            KOFTableConstants.SUPERVIPCONFIG,
            KOFTableConstants.OPERATORCONFIG,
            KOFTableConstants.RESOURCEINSTANCE,
            KOFTableConstants.RESOURCEINSTANCEDIFFICULTY,
            KOFTableConstants.RESOURCEEXPCONSTANCE,
            KOFTableConstants.ARTIFACTSOULINFO,
            KOFTableConstants.ARTIFACTCOLOUR,
            KOFTableConstants.ARTIFACTSOULQUALITY,
            KOFTableConstants.ARTIFACTCONSTANT,
            KOFTableConstants.ARTIFACTBASICS,
            KOFTableConstants.ARTIFACTBREAKTHROUGH,
            KOFTableConstants.ARTIFACTQUALITY,
            KOFTableConstants.ARTIFACTSUIT,
            KOFTableConstants.TALENT_SOUL,
            KOFTableConstants.FRIENDCONFIG,
            KOFTableConstants.SHOP,
            KOFTableConstants.SHOP_ITEM,
            KOFTableConstants.SHOP_REFRESH,
            KOFTableConstants.CULTIVATE_BASE,
            KOFTableConstants.CULTIVATE_DESC,
            KOFTableConstants.CULITIVATE_BUFF,
            KOFTableConstants.CULITIVATE_CONSTANT,
            KOFTableConstants.CULITIVATE_RAND_BUFF_COST,

            KOFTableConstants.SUGGESTCONFIG,
            KOFTableConstants.CLUBUPGRADEBASIC,
            KOFTableConstants.CLUBCONSTANT,
            KOFTableConstants.CLUBPOSITION,
            KOFTableConstants.INVESTCONSUMEREWARD,
            KOFTableConstants.LUCKYBAGCONFIG,


            KOFTableConstants.TUTOR_GROUP,
            KOFTableConstants.TUTOR_ACTION,
            KOFTableConstants.TUTOR_TXT,

            KOFTableConstants.IMPRESSION,
            KOFTableConstants.IMPRESSION_LEVEL,
            KOFTableConstants.IMPRESSION_PROPERTY,
            KOFTableConstants.IMPRESSION_TITLE,
            KOFTableConstants.BUBBLE_MSG,
            KOFTableConstants.IMPRESSION_TASK,
            KOFTableConstants.ImpressionTotalLevelAddProperty,

            KOFTableConstants.NEW_SERVER_REWARD,
            KOFTableConstants.TOTAL_SIGNIN_REWARD,
            KOFTableConstants.SIGNIN_REWARD,

            KOFTableConstants.ENHANCE_ABILITY,
            KOFTableConstants.BUNDLE_ENABLE,
            KOFTableConstants.TASKCALLUP,

            KOFTableConstants.CARD_MONTH_CONFIG,
            KOFTableConstants.CALLUPCONSTANT,

            KOFTableConstants.CARDPLAYER_ACTIVITY,
            KOFTableConstants.CARDPLAYER_POOL,
            KOFTableConstants.CARDPLAYER_TIMES,
            KOFTableConstants.SHOWITEM,
            KOFTableConstants.EUROPEAN_MONEY,
            KOFTableConstants.FREE_SET,
            KOFTableConstants.COUPLERELATIONSHIP,
            KOFTableConstants.TEAMADDITION,
            KOFTableConstants.CARDPlAYERCONSTANT,
            KOFTableConstants.NEWSERVERSHOWITEM,
            KOFTableConstants.NEWSERVERTIMES,
            KOFTableConstants.AllSHOWITEM,

            KOFTableConstants.HEROQUALITYADDITION,
            KOFTableConstants.HEROSTARADDITION,
            KOFTableConstants.TEAMLEVELADDITION,

            KOFTableConstants.TENCENT_FRESH_PRIVILEGE,
            KOFTableConstants.TENCENT_DAILY_PRIVILEGE,
            KOFTableConstants.TENCENT_LEVEL_PRIVILEGE,

            KOFTableConstants.CHATCONSTANT,
            KOFTableConstants.HANGUP_BATTLE_ADDITION,
            KOFTableConstants.HANGUP_LEVEL_ADDITION,
            KOFTableConstants.HANGUP_SKILL_VIDEO,

            KOFTableConstants.EQUIPCARD_POOL,
            KOFTableConstants.EQUIPCARD_TIMES,
            KOFTableConstants.EQUIPSHOWITEM,

            KOFTableConstants.SKILLBUY,

            KOFTableConstants.SYSTEMCONSTANT,
            KOFTableConstants.WORLD_BOSS_CONSTANT,
            KOFTableConstants.WORLD_BOSS_TREASURE_BUY_PRICE,
            KOFTableConstants.WORLD_BOSS_TREASURE_RATIO,
            KOFTableConstants.WORLD_BOSS_REWARD_GOLD,
            KOFTableConstants.WORLD_BOSS_PROPERTY,
            KOFTableConstants.WORLD_BOSS_RANK_REWARD,
            KOFTableConstants.WORLD_BOSS_REVIVE_PRICE,
            KOFTableConstants.WORLD_BOSS_CHAT_CONTENT,

            KOFTableConstants.TREASUREDISPLAYITEM,
            KOFTableConstants.TREASURECARDPOOL,
            KOFTableConstants.TREASUREACTIVITYINFO,

            KOFTableConstants.ArenaBubble,
            KOFTableConstants.ArenaChangeBatch,
            KOFTableConstants.ArenaConstant,
            KOFTableConstants.ArenaHighestRanking,
            KOFTableConstants.ArenaRankingReward,
            KOFTableConstants.ArenaTimeDeplete,

            KOFTableConstants.SEVEN_DAYS,
            KOFTableConstants.FirstRecharge,
            KOFTableConstants.FirstRechargeTips,
            KOFTableConstants.DailyRecharge,
            KOFTableConstants.OneDiamondReward,
            KOFTableConstants.ACTIVITY,
            KOFTableConstants.TOTALCONSUME_ACTIVITY,
            KOFTableConstants.TOTALCHARGE_ACTIVITY,
            KOFTableConstants.DISCOUNT_SHOP,
            KOFTableConstants.ACTIVE_TASK,
            KOFTableConstants.NEW_SERVER_ACTIVITY,

            KOFTableConstants.PAY_PRODUCT,
            KOFTableConstants.LIMITACTIVITY_RANKCONFIG,
            KOFTableConstants.LIMITACTIVITY_SCORECONFIG,
            KOFTableConstants.LIMITACTIVITY_CONST,
            KOFTableConstants.LIMITACTIVITY_CONSUME,
            KOFTableConstants.ITEM_GET_PATH,
            KOFTableConstants.SKILLGETCONDITION,

            KOFTableConstants.CARNIVALACTIVITY_CONFIG,
            KOFTableConstants.CARNIVALACTIVITY_ENTRY_CONFIG,
            KOFTableConstants.CARNIVALACTIVITY_TARGET_CONFIG,
            KOFTableConstants.CARNIVALACTIVITY_REWARD_CONFIG,

            KOFTableConstants.HANGUP_CONSTANT,

            KOFTableConstants.UPDATENOTICECONFIG,

            KOFTableConstants.EndlessTowerConst,
            KOFTableConstants.EndlessTowerLayerConfig,
            KOFTableConstants.EndlessTowerSegmentConfig,
            KOFTableConstants.EndlessTowerRobotConfig,
            KOFTableConstants.RobotPlayer,
            KOFTableConstants.RobotHero,
            KOFTableConstants.CLUBBOSSBASE,
            KOFTableConstants.CLUBBOSSCONSTANT,
            KOFTableConstants.CLUBBOSSPROPERTY,
            KOFTableConstants.CLUBBOSSRANKREWARD,
            KOFTableConstants.CLUBBOSSRANKSINGLE,
            KOFTableConstants.CLUBBOSSREVIVEPRICE,
            KOFTableConstants.Peak1v1Reward,
            KOFTableConstants.Peak1v1Constant,
            KOFTableConstants.Peak1v1AlwaysWinScore,
            KOFTableConstants.WECHATCONFIG,
            KOFTableConstants.BUYRESETTIMESCONFIG,
            KOFTableConstants.SPECIALREWARD,
            KOFTableConstants.LATTICEREWARD,
            KOFTableConstants.BUBBLE,
            KOFTableConstants.SEQUENCEOFPOPUP,
            KOFTableConstants.FLAGDES,
            KOFTableConstants.INVESTCONST,
            KOFTableConstants.INVESTREWARDCONFIG,
            KOFTableConstants.RECHARGEREBATE,

            KOFTableConstants.LEVELUPREWARD7k7k,
            KOFTableConstants.SEVENKREWARDCONFIG,
            KOFTableConstants.DIAMOND_ROULETTE_CONFIG,
            KOFTableConstants.DIAMOND_ROULETTE_CONST,
            KOFTableConstants.DRECHARGE_EXTRA_CONST,

            KOFTableConstants.YYREWAEDCONFIG,
            KOFTableConstants.YYLOGINREWARD,
            KOFTableConstants.YYGAMELEVELREWARD,
            KOFTableConstants.YYLEVELREWARD,
            KOFTableConstants.YYVIPLEVELREWARD,
            KOFTableConstants.YYVIPDAYWELFARE,
            KOFTableConstants.YYVIPWEEKWELFARE,

            KOFTableConstants.ActivitySchedule,
            KOFTableConstants.ACTIVITYCONST,

            KOFTableConstants.GuildWarAlwaysWin,
            KOFTableConstants.GuildWarBuff,
            KOFTableConstants.GuildWarConstant,
            KOFTableConstants.GuildWarExtraSpaceReward,
            KOFTableConstants.GuildWarReward,
            KOFTableConstants.GuildWarSpaceTable,
            KOFTableConstants.GuildWarReport,
            KOFTableConstants.FirstOccupyReward,
            KOFTableConstants.RANKCONFIG,

            KOFTableConstants.FOREVER_RECHARGE_REWARD,

            KOFTableConstants.RECRUIT_ACTIVITY_CONFIG,
            KOFTableConstants.RECRUIT_ACTIVITY_CONST,
            KOFTableConstants.RECRUIT_ACTIVITY_RANK_CONFIG,
            KOFTableConstants.RECRUIT_ACTIVITY_TIMES_CONFIG,
            KOFTableConstants.INSTANCE_LOAD,
            KOFTableConstants.SKILLVIDEO,

            KOFTableConstants.EFFORT_CONFIG,
            KOFTableConstants.EFFORT_CONST,
            KOFTableConstants.EFFORT_STAGE_CONFIG,
            KOFTableConstants.EFFORT_TARGET_CONFIG,
            KOFTableConstants.EFFORT_TYPEREWARD_CONFIG,


            KOFTableConstants.STREET_FIGHTER_REWARD,
            KOFTableConstants.BOSS_CHALLENGE_BASE,
            KOFTableConstants.BOSS_CHALLENGE_PROP,
            KOFTableConstants.BOSS_CHALLENGE_CONST,
            KOFTableConstants.THANKSMESSAGE,

            KOFTableConstants.PLATFORM_MOBILE_REGIST,
            KOFTableConstants.PlatFormBoxLoginReward,

            KOFTableConstants.STORY_CONSTANT,
            KOFTableConstants.STORY_HERO,
            KOFTableConstants.STORY_GATE,
            KOFTableConstants.STORY_CONSUME,

            KOFTableConstants.TitleTypeConfig,
            KOFTableConstants.TitleConfig,

            KOFTableConstants.ACTIVITY_TREASURE_TASK,
            KOFTableConstants.ACTIVITY_TREASURE_BOX,
            KOFTableConstants.ACTIVITY_TREASURE_REPOSITORY,

            KOFTableConstants.TalentSoulSuit,
            KOFTableConstants.TalentOpenCondition,
            KOFTableConstants.TalentSoulFurnace,

            KOFTableConstants.RETRIEVESYSTEMCONFIG,

            KOFTableConstants.RETRIEVEREWARD,

            KOFTableConstants.GemConstant,
            KOFTableConstants.GemPoint,
            KOFTableConstants.Gem,
            KOFTableConstants.GemSuit,

            KOFTableConstants.STRENGTHEN_CONSTANTS,
            KOFTableConstants.STRENGTHEN_BATTLE_VALUE_TARGET,
            KOFTableConstants.STRENGTHEN_ITEM,
            KOFTableConstants.STRENGTHEN_TYPE,
            KOFTableConstants.STRENGTHEN_LEVEL_BATTLE_VALUE,
            KOFTableConstants.STRENGTHEN_BATTLE_VALUE_CALC,

            KOFTableConstants.LOTTERYCONFIG,
            KOFTableConstants.LOTTERYCONSUME,
            KOFTableConstants.LOTTERYSHOW,
            KOFTableConstants.ACTIVITY_PREVIEW,

            KOFTableConstants.FunctionNotice,
            KOFTableConstants.FuncOpenCondition,

            KOFTableConstants.ChargeActivityNotice
        ];

        private var m_pManifestIDs : Object = {};

        /** @private */
        private var m_pDataBase : CMap;
        /** @private */
        private var m_listValidator : Vector.<Function>;
        /** @private */
        private var m_pProcedureManager : CProcedureManager;

        private var m_fnLoadPackedConfigFinish : Function;

        private var m_thePackedResource : CResource;

        /** Creates a new CDatabaseSystem. */
        public function CDatabaseSystem() {
            super();

            m_listValidator = new <Function>[];

            m_pManifestIDs[ KOFTableConstants.PLAYER_BASIC ] = "ID";
            m_pManifestIDs[ KOFTableConstants.AUDIO ] = "name";
            m_pManifestIDs[ KOFTableConstants.BUNDLE_ENABLE ] = "TagID";

        }

        /** @inheritDoc */
        override public function dispose() : void {
            super.dispose();

            if ( m_pProcedureManager ) {
                m_pProcedureManager.dispose();
            }

            m_pProcedureManager = null;

            if ( m_pDataBase ) {
                for each ( var pTable : CDataTable in m_pDataBase ) {
                    if ( pTable ) {
                        pTable.dispose();
                    }
                }

                m_pDataBase.clear();
            }

            m_pDataBase = null;

            if ( m_listValidator ) {
                m_listValidator.splice( 0, m_listValidator.length );
            }

            m_listValidator = null;

            if ( m_thePackedResource != null ) {
                m_thePackedResource.dispose();
                m_thePackedResource = null;
            }
            m_fnLoadPackedConfigFinish = null;
        }

        /** @inheritDoc */
        override protected function onSetup() : Boolean {
            var ret : Boolean = super.onSetup();
            if ( ret ) {
                m_pProcedureManager = new CProcedureManager( 30 );

                m_pProcedureManager.addSequential( _loadDataRuntime );
                m_pProcedureManager.addSequential( _hangupByCodeImport );

                function loadConfigFile() : void {
                    var filePath : String;
                    var clazzName : String;
                    var tableName : String;
                    for ( var i : int = 0; i < m_pManifest.length; ++i ) {
                        tableName = m_pManifest[ i ];
                        filePath = "assets/table/" + tableName;
                        clazzName = KOFTableConstants.getClassName( tableName );
                        m_pProcedureManager.addParallel( _loadConfigData, tableName, filePath, clazzName );
                    }

                    m_pProcedureManager.addSequential( _loadComplete );
                }

                if ( CPackedQsonLoader.enablePackedQsonLoading == true ) {
                    _loadPackedConfigFile( loadConfigFile );
                }
                else {
                    loadConfigFile();
                    m_pProcedureManager.addSequential( _loadComplete );
                }

                m_pDataBase = new CMap();
            }

            return false; // blocking setStarted, make started when all the DataTable was loaded.
        }

        /** @inheritDoc */
        override protected function doStop() : Boolean {
            var ret : Boolean = super.doStop();
            if ( ret ) {
                if ( m_pProcedureManager ) {
                    m_pProcedureManager.dispose();
                }

                m_pProcedureManager = null;
            }
            return ret;
        }

        /** @inheritDoc */
        override protected function enterStage( appStage : CAppStage ) : void {
            super.enterStage( appStage );
        }

        /** @inheritDoc */
        override protected function exitStage( appStage : CAppStage ) : void {
            super.exitStage( appStage );
        }

        /** @private  */
        final private function _loadPackedConfigFile( callback : Function ) : void {
            m_fnLoadPackedConfigFinish = callback;
            var packedFile : String = "assets/table/table_packed";
            m_pProcedureManager.addSequential( _loadPackedConfigData, packedFile );
        }

        /** @private */
        final private function _loadDataRuntime( theProcedureTags : Object ) : Boolean {
            if ( theProcedureTags.lastProcedureTag && theProcedureTags.lastProcedureTag.result == false )
                return false;

            var bDone : Boolean = false;

            // Pull out the "assets/bin/GameDataRuntime.swf" into application configuration.
            var swfGDR : String = "assets/bin/GameDataRuntime.swf";

            CResourceLoaders.instance().startLoadFile( swfGDR, _onFinished );

            function _onFinished( pLoader : CSwfLoader, idError : int ) : void {
                if ( 0 == idError ) {
                    var pSwf : DisplayObject = pLoader.createObject() as DisplayObject;
                    stage.flashStage.addChild( pSwf );
                    bDone = true;
                } else {
                    LOG.logErrorMsg( "Loading DataRuntime failed." );
                }
            }

            theProcedureTags.isProcedureFinished = function () : Boolean {
                return bDone;
            };

            return true;
        }

        final private function _hangupByCodeImport( theProcedureTags : Object ) : Boolean {
            if ( theProcedureTags.lastProcedureTag && theProcedureTags.lastProcedureTag.result == false )
                return false;
            return true;
        }

        final private function _loadPackedConfigData( theProcedureTags : Object ) : Boolean {
            if ( theProcedureTags.lastProcedureTag && theProcedureTags.lastProcedureTag.result == false )
                return false;

            var filePath : String = String( theProcedureTags.arguments[ 0 ] );
            var vPackedFile : Vector.<String> = new Vector.<String>( 2 );
            vPackedFile[ 0 ] = filePath + ".qson";
            vPackedFile[ 1 ] = filePath + ".json";
            CResourceLoaders.instance().startLoadFileFromPathSequence( vPackedFile, _onFinished, CPackedQsonLoader.NAME, ELoadingPriority.HIGH, false );

            function _onFinished( loader : CPackedQsonLoader, idError : int ) : void {
                if ( idError == 0 ) {
                    m_thePackedResource = loader.createResource();
                }

                if ( m_fnLoadPackedConfigFinish != null ) m_fnLoadPackedConfigFinish();
            }

            return true;
        }

        /** @private */
        final private function _loadConfigData( theProcedureTags : Object ) : Boolean {
            if ( theProcedureTags.lastProcedureTag && theProcedureTags.lastProcedureTag.result == false )
                return false;

            var bDone : Boolean = false;
            var fileName : String = String( theProcedureTags.arguments[ 0 ] );
            var filePath : String = String( theProcedureTags.arguments[ 1 ] );
            var clazzName : String = String( theProcedureTags.arguments[ 2 ] );

            if ( !fileName || fileName.length == 0 )
                return false;

            if ( !filePath || filePath.length == 0 )
                return false;

            CResourceLoaders.instance().startLoadFile( filePath + ".json", _onFinished,
                    CJsonLoader.NAME, ELoadingPriority.HIGH, false, false, _onProgress );

            /** @private */
            function _onProgress( theJson : CJsonLoader, nBytesLoaded : uint, nTotalBytes : uint ) : void {
                // Ignore.
            }

            function toMap( theJson : Object, sKey : String, cls : Class = null, mapTable : CMap = null ) : CMap {
                if ( theJson == null ) return null;

                if ( mapTable == null ) mapTable = new CMap();
                for ( var i : int = 0; i < theJson.length; i++ ) {
                    if ( theJson[ i ].hasOwnProperty( sKey ) ) {
                        if ( cls != null ) {
                            mapTable.add( theJson[ i ][ sKey ], new cls( theJson[ i ] ) );
                        } else {
                            mapTable.add( theJson[ i ][ sKey ], theJson[ i ] );
                        }
                    }
                }

                return mapTable;
            }

            /** @private */
            function _onFinished( theLoader : CJsonLoader, idError : int ) : void {
                if ( 0 == idError ) {
                    // Load success.
                    try {
                        var pKofTableNamespace : Namespace = new Namespace( "kof.table" );
                        var pQName : QName = new QName( pKofTableNamespace, clazzName );

                        var fileClass : Class = ApplicationDomain.currentDomain.getDefinition( pQName.toString() ) as Class;
                        if ( fileClass ) {

                            var vObj : Object = theLoader.createObject();

                            var pTable : CDataTable;
                            if ( m_pManifestIDs && fileName in m_pManifestIDs ) {
                                pTable = new CDataTable( fileName, m_pManifestIDs[ fileName ] );
                            } else {
                                pTable = new CDataTable( fileName );
                            }

                            pTable.initWithMap( toMap( vObj, pTable.primaryKey, fileClass ) );

                            m_pDataBase.add( pTable.name, pTable );
                        }

                    } catch ( e : Error ) {
                        LOG.logErrorMsg( "Processing external config netData assignment cause failed: " + e.message );
                    }

                } else {
                    LOG.logErrorMsg( "Load external config netData (" + theLoader.filename + ") failed." );
                }

                bDone = true;
            }

            var iCounter : int = 0;

            theProcedureTags.isProcedureFinished = function () : Boolean {
//            iCounter++;
//            if (iCounter >= 20)
                return bDone;
//            return false;
            };

            return true;
        }

        /** @private */
        final private function _loadComplete( theProcedureTags : Object ) : Boolean {
            // Calls when all config netData load completed.

            if ( theProcedureTags.lastProcedureTag && theProcedureTags.lastProcedureTag.result == false )
                return false;

            this.setComplete();
            return true;
        }

        private var m_bCompleted : Boolean;

        final public function get isReady() : Boolean {
            return m_bCompleted;
        }

        final private function setComplete() : void {
            m_bCompleted = true;
            // this.dispatchEvent( new Event( Event.COMPLETE ) );
            makeStarted();

            // run all validator
            if ( m_listValidator && m_listValidator.length ) {
                for each ( var pfn : Function in m_listValidator ) {
                    runValidator( pfn );
                }
            }
        }

        /** Returns the target CDataTable specify by the <code>sTableName</code>. */
        final public function getTable( sTableName : String ) : IDataTable {
            if(m_pDataBase){
                return m_pDataBase.find( sTableName ) as IDataTable;
            }
           return null;
        }

        /**
         * @inheritDoc
         */
        public function addValidator( pfnValidator : Function ) : void {
            if ( null == pfnValidator )
                return;

            var idx : int = m_listValidator.indexOf( pfnValidator );
            if ( idx == -1 ) {
                m_listValidator.push( pfnValidator );
            }

            if ( isReady ) {
                this.runValidator( pfnValidator );
            }
        }

        /**
         * @inheritDoc
         */
        public function removeValidator( pfnValidator : Function ) : void {
            if ( null == pfnValidator )
                return;

            var idx : int = m_listValidator.indexOf( pfnValidator );
            if ( idx > -1 ) {
                m_listValidator.splice( idx, 1 );
            }
        }

        protected function runValidator( pfnValidator : Function ) : void {
            if ( null == pfnValidator )
                return;

            pfnValidator( this );
        }

    }
}
