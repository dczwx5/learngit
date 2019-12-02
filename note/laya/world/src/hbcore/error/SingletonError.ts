export default class SingletonError extends Error {
    constructor() {
        super("SingletonError::Singleton class!");
    }
}