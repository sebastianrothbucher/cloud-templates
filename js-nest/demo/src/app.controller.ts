import { All, Controller, Get, Header, Req } from '@nestjs/common';
import { Request } from 'express';

@Controller()
export class AppController {
  constructor() {}

  @Get('one')
  @Header('Content-type', 'text/plain')
  one(): string {
    return 'one';
  }

  @Get('two')
  two(): { content } {
    return { content: 'two' };
  }

  @All('three/?*')
  trhee(@Req() req: Request) {
    return {
      method: req.method,
      path: req.path,
      headers: req.headers,
      query: req.query,
    }
  }

}
