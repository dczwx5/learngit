namespace VL {
    export namespace Reflector {
        export class EgretReflector implements VL.Reflector.IReflector {

            public getClassName(classOrEntity: any): string {
                return egret.getQualifiedClassName(classOrEntity);
            }

            public getClass<T extends new(...args) => T>(className: string): T {
                return egret.getDefinitionByName(className);
            }

            public getClassByEntity<T>(entity: T): { new(...args): T } | { new(): T } {
                if (!entity) {
                    return null;
                }
                return entity['__proto__'].constructor;
            }

            public isExtends(extClass: any, baseClassName: string): boolean {
                let extClassNmae = this.getClassName(extClass);
                return baseClassName != extClassNmae && extClass['prototype']['__types__'].indexOf(baseClassName) >= 0;
            }
        }
    }
}