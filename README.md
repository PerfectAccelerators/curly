# Curly - WIP

If you need to call an API in your Server Side Swift then you can simply use Curly! 
It simplifies and standaridizes the _cURL_ calls by providing convenience methods.

## Features

- A protocol to define all the API dependencies `ClientAPIProtocol`
- Automatic JSON Model mapping for requests and responses with Codables `ClientAPIMappingHelper`
- Standard error handling with `ClientAPIError: Error, Codable`
- HTTP Client 
- Client REST Protocol with extension that provides `consume` and `produce` for `GET` and `POST` calls out of the box

