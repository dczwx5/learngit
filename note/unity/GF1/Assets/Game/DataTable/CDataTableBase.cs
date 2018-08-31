using GameFramework.DataTable;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
public abstract class CDataTableBase : IDataRow {

	public int Id {
        get;
        protected set;
    }

    // override
    virtual public void ParseDataRow(string dataRowText) {

    }


    protected static readonly string[] S_ColumnSplit = new string[] { "\t" };
}
