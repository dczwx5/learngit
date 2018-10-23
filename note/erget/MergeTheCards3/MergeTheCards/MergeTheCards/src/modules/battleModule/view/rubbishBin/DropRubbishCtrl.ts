class DropRubbishCtrl extends DropCardContainerCtrl{

    protected checkEnableDrop(dragItem: Card): boolean {
        return this.rubbishBin.rubbishCount < PublicConfigHelper.MAX_RUBBISH_COUNT;
    }

    private get rubbishBin():RubbishBin{
        return this.container as RubbishBin;
    }
}
