package kof.game.perfs {

public interface IGamePerfData {

    function get minFrameRate() : Number;

    function get maxFrameRate() : Number;

    function get avgFrameRate() : Number;

    function get minMemUsage() : Number;

    function get maxMemUsage() : Number;

    function get avgMemUsage() : Number;

}
}
