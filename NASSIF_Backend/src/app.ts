import express from 'express'
import path from 'path'
import fs from 'fs'
import cors from 'cors'
import Controller from '@/utils/interfaces/controller.interface'
import mongoose from "mongoose"
import morgan from 'morgan'
import bodyParser from 'body-parser'
import compression from 'compression'
import passport from 'passport'
import cookieParser from 'cookie-parser'
import session from 'express-session';
import { CronJob } from 'cron'
import errorMiddleware from '@/middleware/errorMiddleware'
import CronService from '@/utils/services/cron.service'
import SocketService from '@/utils/services/socket.service'

class App {
    public express: express.Application
    public port: number

    constructor(
        controllers: Controller[], 
        port: number
    ){
        this.express = express()
        this.port = port

        this.initialiseDatabaseConnection()
        this.initialiseMiddleware()
        this.initialiseControllers(controllers)
        this.initialiseErrorHandling()
        this.initialiseDefaultConfiguration()
        this.initialiseCron()
    }

    private initialiseDatabaseConnection(): void {
        const MONGO_URI = `mongodb+srv://${process.env.MONGO_USER}:${process.env.MONGO_PASSWORD}@${process.env.MONGO_PATH}`
        const connection = mongoose.connection

        connection.on('connected', () => {
          console.log('Mongo Connection Established')
        })

        connection.on('reconnected', () => {
          console.log('Mongo Connection Reestablished')
        })

        connection.on('disconnected', () => {
          console.log('Mongo Connection Disconnected')
          console.log('Trying to reconnect to Mongo ...')
          setTimeout(() => {
            mongoose.connect(MONGO_URI, {
            //   autoReconnect: true,
              socketTimeoutMS: 3000,
              connectTimeoutMS: 3000,
            })
          }, 3000)
        })
        connection.on('close', () => {
          console.log('Mongo Connection Closed')
        })
        connection.on('error', (error: Error) => {
          console.log('Mongo Connection ERROR: ' + error)
        })
    
        const run = async () => {
          await mongoose.connect(MONGO_URI)
        }
        run().catch((error) => console.error(error))
    }

    private initialiseMiddleware(): void {
      this.express.use(express.static(path.join(__dirname, './public')))
      this.express.use(cors())
      this.express.use(morgan('dev'))
      this.express.use(express.json({limit: '150mb'}))
      this.express.use(express.urlencoded({limit: '150mb', extended: false }))
      this.express.use(bodyParser.json({limit: '150mb'}));
      this.express.use(bodyParser.urlencoded({limit: '150mb', extended: true }))
      this.express.use(compression())
      this.express.use(session({ secret: `${process.env.JWT_SECRET}`, resave: true, saveUninitialized: true, cookie: { maxAge: 1000 * 60, secure: true}}))
      this.express.use(passport.initialize())
      this.express.use(cookieParser())
    }

    private initialiseControllers(controllers: Controller[]): void {
      controllers.forEach((controller: Controller) => {
          this.express.use(`${process.env.URL_PREFIX}/v${process.env.VERSION}`, controller.router);
      });
    }

    private initialiseErrorHandling(): void {
      this.express.use(errorMiddleware);
    }

    private initialiseCron(): void {
      const cronService = new CronService()

      let auction: CronJob;
      auction = new CronJob('1 * * * * *', async () => {
        cronService.test()
      });
      if (!auction.isActive) {
        auction.start();
      }
    }

    private initialiseDefaultConfiguration(): void {
      console.log('Setup default configuration')


      console.log('Setup default configuration completed')
    }

    public listen(): void {
      const server = this.express.listen(this.port, () => {
          console.log(`App listening on the port ${this.port}`);
      });
      new SocketService(server)
    }
    
}

export default App