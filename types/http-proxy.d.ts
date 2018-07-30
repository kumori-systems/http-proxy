import { EventEmitter} from 'events'

export declare class HttpProxy extends EventEmitter {
    private logger;
    private server;
    private nodeProxy;

    constructor(server: string, ip: string, port: number);
}