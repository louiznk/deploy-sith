-- prod.dhall
-- config for production env

-- schemas
let ConfigDeploy = ../types/sith-config-deploy.dhall

let ConfigSvc = ../types/sith-config-svc.dhall
let Port : Type = < Int : Integer | String : Text >

let Config = ../types/sith-config.dhall

-- create ingress from svc
let Converters = ../tools/converters.dhall 

-- common
let common = {
  name = "hello",
  app = "hello",
}

-- deployment
let deployment = ConfigDeploy::{
  name = common.name,
  app = common.app,
  replicas = +2,
  image = "registry.gitlab.com/gitops-heros/sith:1.0",
  containerPort = +8080,
  portName = Some "web",
  environnement = Some "production",
  resources = {
    requests = { cpu = "0.5", memory = "16Mi" },
    limits = { cpu = "1", memory = "32Mi" }
  },
  livenessProbe = { path = "/", port = Port.String "web" }
}

-- svc
let service = ConfigSvc::{
  name = common.name,
  app = common.app,
  port = +80,
  portName = Some "front",
  targetPort = Some (Port.String "web")
}

-- ingress (from svc)
let ingress = Converters.configServiceToconfigIngress service "prod.127.0.0.1.sslip.io"

let config : Config = {deploy = deployment, svc = service, ing = ingress}

in config
