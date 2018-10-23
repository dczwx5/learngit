class NickNameFilter {
    public static filter(nickName: string, maxCharCount: number = 6): string {
        if (nickName.length > maxCharCount) {
            return nickName.substr(0, maxCharCount - 1) + "...";
        } else {
            return nickName;
        }
    }
}