
namespace Core {

public class CAssetsPath {
    public static string GetDatatTablePath(string tableName) {
        return string.Format("Assets/Res/DataTable/{0}.txt", tableName);
    }
    public static string GetScenePath(string sceneName) {
        return string.Format("Assets/Scenes/{0}.unity", sceneName);
    }
}

}