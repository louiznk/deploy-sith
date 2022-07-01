-- staging.dhall
-- config for staging env

-- schemas
let ConfigDeploy = ../types/sith-config-deploy.dhall

let ConfigSvc = ../types/sith-config-svc.dhall
let Port : Type = < Int : Integer | String : Text >

let ConfigSealedSecret = ../types/sith-config-sealed-secret.dhall
let ConfigSealedSecretType = ../types/sith-config-sealed-secret-type.dhall


let Config = ../types/sith-config.dhall

-- create ingress from svc
let Converters = ../tools/converters.dhall 

-- common
let common = {
  name = "hello",
  app = "hello",
  secretName = "james-secrets",
}

-- deployment
let deployment = ConfigDeploy::{
  name = common.name,
  app = common.app,
  replicas = +1,
  image = "registry.gitlab.com/gitops-heros/sith:1.3",
  containerPort = +8080,
  portName = Some "web",
  environnement = Some "secret",
  resources = {
    requests = { cpu = "0.2", memory = "8Mi" },
    limits = { cpu = "0.5", memory = "16Mi" }
  },
  livenessProbe = { path = "/", port = Port.String "web" },
  secretName = Some common.secretName
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
let ingress = Converters.configServiceToconfigIngress service "secret.127.0.0.1.sslip.io"


-- sealed secret
let sealedSecret = ConfigSealedSecret::{
  name = common.secretName,
  app = "hello",
  encryptSecret =
      "AgA6OLQpfM7GJ/pDpqW8wPcqXVFyYuZKw+IiOJje2nrDXC/dLYel+tuFFH6HIwv4eonDnJbkvcLYnVC72BT5AJcgrulwzt3bW7KXNN0Xv4N3KDi09p4ALCnKZ0UodxUh1/52reYAy3seNbH2WclJCMB9zLeRE3csfdmjwUPjwQKUlKIEpC5E73B4J7UlquezIrPCDkK4aePHjni7lNChwdy136PVWejsvcO5zV0xTT5Z1K3A/7eyCj8yJlJg2rSfli05zVoPBXmZUs9w/RdLitM1fCzuxUBJPZ7C8KIDKb1sLmKclGcAEIQsNxeukRTfkp2NAqbx3S6XJyUlylm/6X0eHoJHq1JBHl4/wyABaMA5txjXA651t+/tXpytHzK6RiYcwtqSLCxPV+APY3TNwoonn2mEEC8qdf5YbZ7CITJaK2cenLfDmvyrvZ80CtK7cAC4yQYX6M+KA432QLNK4lHptHGMbgJsm0gO+QGmRzw+FcUKtS9+T0w64opbPe8k3BxfSaWqzYdWWSE3Zkjqh3XQ3jTc4vJX2J3A3FUBhQxtkfRvTIatCmgZ50PY4y0hd8Is/eqGrYTFEGInsRH3YF9fM7X32m4NwATa2FiVTd6qtRDLlBoc0b//twOj0ctjk9Pm0Mcf5RfZrVceZtyAEsILw4P2NM1yS7yaWWHKV/hsHHAAe3LHnuuL/qFLIGQdrVW5wAO8IBfx3cuHXcWJZ3IInFGfF3QGaK8=",
  -- annotations = ConfigSealedSecretType.namespaceWide,
  -- namespace = Some "namespace"
}

let config : Config ={deploy = deployment, svc = service, ing = ingress}
--, sealed = sealedSecret}

in config ∧ { sealed = sealedSecret}
