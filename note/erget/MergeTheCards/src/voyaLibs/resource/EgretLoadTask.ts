namespace VL {
    export namespace Resource {
        export interface EgretLoadTask {
            keys: string[],
            taskName: string,

            onComplete?: (task: EgretLoadTask) => void,
            onCancel?: (task: EgretLoadTask) => void,
            onProgress?: (task: EgretLoadTask, curr: number, total: number) => void
        }
    }
}
