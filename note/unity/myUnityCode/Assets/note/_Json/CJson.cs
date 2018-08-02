using UnityEngine;
using System.Collections;
using System.IO;
using System;

public class CJson : MonoBehaviour {

    // Use this for initialization
    void Start() {
        _jsonDataSaveToFile(); // toJson
        _readFileToJsonData(); // FromJson
    }

    private void _jsonDataSaveToFile() {
        Debug.Log("_jsonDataSaveToFile");

        JHeroData heroData = new JHeroData();
        heroData.level = 99;
        heroData.ID = 1001;
        heroData.exp = 3131;
        heroData.quality = 3;
        heroData.star = 4;

        JEquipData[] equipListData = new JEquipData[3];
        JEquipData equipData = new JEquipData();
        equipData.type = 1;
        equipData.level = 2;
        equipData.star = 3;
        equipData.name = "龙泉剑";
        equipListData[0] = equipData;
        heroData.weaponData = equipData;

        equipData = new JEquipData();
        equipData.type = 2;
        equipData.level = 3;
        equipData.star = 1;
        equipData.name = "背甲衣";
        equipListData[1] = equipData;

        equipData = new JEquipData();
        equipData.type = 3;
        equipData.level = 1;
        equipData.star = 2;
        equipData.name = "青掮";
        equipListData[2] = equipData;
        heroData.equipListData = equipListData;

        string jsonStringData = JsonUtility.ToJson(heroData);
        string path = Path.Combine(Application.persistentDataPath, "testHeroData.txt");
        Debug.Log(path);
        CFile.WriteFile(path, jsonStringData, false);
    }

    private void _readFileToJsonData() {
        Debug.Log("_readFileToJsonData");
        string path = Path.Combine(Application.persistentDataPath, "testHeroData.txt");
        Debug.Log(path);
        string content = CFile.ReadFile(path);
        JHeroData heroData = JsonUtility.FromJson<JHeroData>(content);
        if (null != heroData) {

        }
        Debug.Log(content);
        Debug.Log("end");

    }

    [Serializable]
    public class JHeroData {
        public int ID;
        public int level;
        public int quality;
        public int exp;
        public int star;
        public JEquipData[] equipListData;
        [SerializeField]
        public JEquipData weaponData;
    }
    [Serializable]
    public class JEquipData {
        public int type;
        public int level;
        public int star;
        public string name;
    }


    /**
     "kkk":[1,2,3];
     */

    /**
     "bbb":[{"name":1}, {"name":2}]
    */
}
