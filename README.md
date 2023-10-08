
# ElRollup de LaChain y un nuevo `Create2Deployer``

Bienvenido al repositorio principal de nuestra solución, un rollup usando optimism y un contrato Create2Deployer para mejorar LaChain.


## Contenido del Repositorio

- **Carpeta [`/create2deployer`](./create2deployer/):** Aquí encontrarás el código y los tests de la nueva implementación del contrato Create2Deployer. Esta implementación ha sido realizada utilizando el framework Foundry. Para más detalles, dirígete a la carpeta y consulta el `README` específico de esa sección.

## Configuración de OpStack (Optimism Stack)

Para configurar OpStack y trabajar con nuestra solución, sigue los siguientes pasos:

1. **Instalación:** Asegúrate de tener instalado [OpStack get stareted](https://stack.optimism.io/docs/build/getting-started/) en tu máquina local. Como extra puede revisar el video [Launch your own Rollup with the OP Stack in 30 minutes](https://www.youtube.com/watch?v=PcgAKoUKRv4)

2. **Configuración Inicial:** Rpcs de lachain:`https://rpc1.mainnet.lachain.network`, `https://rpc2.mainnet.lachain.network` y `https://lachain.rpc-nodes.cedalio.dev`,  chainid: 274


3. **Conexión con LaChain:** Para que el opstack funcione se necesita un nodo full archive, lamentablemente ninguno de los nodos actuales es full archive.

4. **Deployment:** Para poder deployear se usar el `create2deployer` como este contracto no existe en lachain y es imposible de deployear decidimos reescribirlo, tambien vamos a necesitar realizar algunas modificaciones en las scripts de deployment.

5. **Sequencer:** Idealmente se deberia armar una imagen en docker para poder correr los servicios del sequencer, pero por ahora se puede correr en local usando las instrucciones descriptas en el punto 1

## Contribuciones y Feedback

Agradecemos cualquier feedback o contribución al proyecto. Si encuentras algún problema o tienes alguna sugerencia, no dudes en abrir un issue o enviar un pull request.

## Licencia

MIT