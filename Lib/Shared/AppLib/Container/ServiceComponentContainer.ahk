class ServiceComponentContainer extends ContainerBase {
    Get(key) {
        serviceObj := super.Get(key)

        if (!serviceObj) {
            throw ServiceNotFoundException.new("Service component '" . key . "' does not exist")
        }

        return serviceObj
    }
}
