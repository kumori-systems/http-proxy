[![semantic-release](https://img.shields.io/badge/%20%20%F0%9F%93%A6%F0%9F%9A%80-semantic--release-e10079.svg)](https://github.com/semantic-release/semantic-release)

# Http Message

Http proxy for Kumori Platform components.

## Description

This module proxifies a legacy http server connections through Kumori's channels (see [Kumori's documentation](https://github.com/kumori-systems/documentation) for more information about channels and Kumori's _service application model_).


## Table of Contents

* [Installation](#installation)
* [Usage](#usage)
* [License](#license)

## Installation

Install it as a npm package

    npm install -g @kumori/http-proxy

## Usage

```javascript
const http = require('@kumori/http-message')
const httpProxy = require('@kumori/http-proxy')
let server = http.createServer()
let host = 'localhost'
let port = 8080
proxy = httpProxy server, host, port
server.listen(channel, (error) => {
    // Do something
})
```

## License

MIT © Kumori Systems
