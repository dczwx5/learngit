//反射的快捷使用


function getClassName(classOrEntity: any): string {
    return app.reflector.getClassName(classOrEntity);
}

function getClass<T extends new(...args) => T>(className: string): T {
    return app.reflector.getClass<T>(className);
}

function getClassByEntity<T>(entity: T): { new(...args): T } | { new(): T } {
    return app.reflector.getClassByEntity(entity);
}

function isExtends(extClass: any, baseClassName: string): boolean {
    return app.reflector.isExtends(extClass, baseClassName);
}
