*** Settings ***
Library     SSHLibrary
Resource    api.resource

*** Test Cases ***
# The game itself is a 70 GB SteamCMD download, far beyond a CI guest: the suite
# checks the module plumbing (install, update, secrets) and never starts the
# server, so configure-module is not called here.
Install the module
    IF    '${SCENARIO}' == 'update'
        ${output}  ${rc} =    Execute Command    add-module ${UPDATE_FROM} 1    return_rc=True
    ELSE
        ${output}  ${rc} =    Execute Command    add-module ${IMAGE_URL} 1    return_rc=True
    END
    Should Be Equal As Integers    ${rc}  0
    &{output} =    Evaluate    ${output}
    Set Global Variable    ${module_id}    ${output.module_id}

Remember the RCON password before the update
    Skip If    '${SCENARIO}' != 'update'    scenario is ${SCENARIO}
    ${h} =    Run on node    runagent -m ${module_id} bash -c 'grep ^RCON_PASSWORD= "$AGENT_STATE_DIR/environment" | sha256sum'
    Set Global Variable    ${RCON_BEFORE}    ${h}

Update to the image under test
    Skip If    '${SCENARIO}' != 'update'    scenario is ${SCENARIO}
    Run on node    api-cli run update-module --data '{"force":true,"module_url":"${IMAGE_URL}","instances":["${module_id}"]}'
    # the migration must move the secret, not regenerate it
    ${h} =    Run on node    runagent -m ${module_id} bash -c 'grep ^RCON_PASSWORD= "$AGENT_STATE_DIR/passwords.env" | sha256sum'
    Should Be Equal    ${h}    ${RCON_BEFORE}

Configuration reads back
    ${cfg} =    Run task    module/${module_id}/get-configuration    {}
    Should Not Be Empty    ${cfg['server_name']}
    Should Not Be True    ${cfg['gslt_token_set']}

Secrets are stored in passwords.env only
    Secrets are kept out of the module environment    ${module_id}
    ${n} =    Run on node    runagent -m ${module_id} bash -c 'grep -c ^RCON_PASSWORD=. "$AGENT_STATE_DIR/passwords.env"'
    Should Be Equal As Integers    ${n.strip()}    1
