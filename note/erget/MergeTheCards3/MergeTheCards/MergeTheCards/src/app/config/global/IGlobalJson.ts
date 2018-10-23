namespace App {
    export interface IGlobalJson {
      client_version: string;
      isDebug: boolean;
      isCDN: boolean;
      // CDN_head_img: string;
      CDN_RESOURCE: string;
      // '//CDN_RESOURCE1': string;
      LOCAL_RESOURCE: string;
      '//pf_Doc': string;
      pf: string;
      videoAdUnitId: string;
      bannerAdUnitId: string;
      '//过度服': string;
      '//testHttpServer': string;
      '//guoduformalHttpServer': string;
      '//formalHttpServer': string;
      '//DaFeiLocal': string;
      HttpServer: string;
      serverPort: string;

    }
}