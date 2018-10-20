//反射的快捷使用
function getClassName(classOrEntity) {
    return app.reflector.getClassName(classOrEntity);
}
function getClass(className) {
    return app.reflector.getClass(className);
}
function getClassByEntity(entity) {
    return app.reflector.getClassByEntity(entity);
}
function isExtends(extClass, baseClassName) {
    return app.reflector.isExtends(extClass, baseClassName);
}
//# sourceMappingURL=Reflector.js.map