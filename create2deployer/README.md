# KOD Optimización del Create2Deployer, CREATE2DEPLOYER Huff rewrite

## REQUIREMENTS
Antes de testear por favor recordar instalar el compilador de huff:
https://docs.huff.sh/get-started/installing/

## Introducción

El contrato `Create2Deployer` es una implementación que permite a los desarrolladores desplegar contratos en multiples chains EVM compatibles utilizando el opcode `CREATE2`. Esto es especialmente útil para desplegar contratos en direcciones específicas de antemano, lo que puede tener ventajas en términos de interoperabilidad y diseño de sistemas.

La dirección original del contrato `Create2Deployer` es `0x4e59b44847b379578588920ca78fbf26c0b4956c`.

## Mejoras Implementadas

Durante este hackaton, hemos reescrito el contrato `Create2Deployer` en el lenguaje de programación Huff. Las principales ventajas de esta reescritura son:

- **Reducción del tamaño del bytecode**: Hemos logrado reducir el tamaño del bytecode de 69 a 33, lo que representa una disminución significativa y optimiza el despliegue del contrato.
  
- **Optimización del gas**: La cantidad de gas requerido para ejecutar ciertas funciones del contrato se ha reducido. Por ejemplo, la función `create2factory` ahora consume 81621 de gas en comparación con los 84168 de gas del contrato original.

## Código Final en Huff

El código final en Huff es el siguiente:

```huff
#define macro MAIN() = takes(0) returns(0) {
  pc                              // 0x00 no PUSH0? no problem!
  0x20                            // 0x00, 0x20
  dup1 calldatasize sub           // 0x00, 0x20, (bytecode size = calldatasize - 0x20)
  dup1                            // 0x00, 0x20, bytecode_size, bytecode_size
  dup3                            // 0x00, 0x20, bytecode_size, bytecode_size, 0x20

  dup5                            // 0x00, 0x20, bytecode_size,  bytecode_size, 0x20, 0x00
  calldatacopy                    // 0x00, 0x20, bytecode_size,
  dup3 calldataload               // 0x00, 0x20, bytecode_size, bytes32
  dup2                            // 0x00, 0x20, bytecode_size, bytes32, bytecode_size
  dup5                            // 0x00, 0x20, bytecode_size, bytes32, bytecode_size, 0x00
  callvalue                       // 0x00, 0x20, bytecode_size, bytes32, bytecode_size, 0x00, callvalue
  create2                         // 0x00, 0x20, bytecode_size, deployed address
  
  // if deployedAddress != 0x00: goto creationOkJump
  dup1 creationOkJump jumpi       // 0xff...e0 + calldatasize, 0x00, hash, deployedAddress
  
  // 0x00 0x00 revert (if deployedAddress == 0x00 revert)
  dup1 revert
  
  creationOkJump:
    dup4 mstore
    0x14 0x0c return
}
```

## Conclusión

La optimización del contrato `Create2Deployer` en Huff ha demostrado ser una mejora significativa en términos de eficiencia y coste de gas. Estas optimizaciones son cruciales en el ecosistema multiples chains EVM compatibles, donde el ahorro de gas puede traducirse en ahorros significativos para los usuarios y desarrolladores.
