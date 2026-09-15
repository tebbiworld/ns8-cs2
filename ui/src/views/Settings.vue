<!--
  Copyright (C) 2026 tebbi
  SPDX-License-Identifier: GPL-3.0-or-later
-->
<template>
  <cv-grid fullWidth>
    <cv-row>
      <cv-column class="page-title"><h2>{{ $t("settings.title") }}</h2></cv-column>
    </cv-row>
    <cv-row v-if="error.getConfiguration">
      <cv-column>
        <NsInlineNotification kind="error" :title="$t('action.get-configuration')" :description="error.getConfiguration" :showCloseButton="false" />
      </cv-column>
    </cv-row>
    <cv-row>
      <cv-column>
        <cv-tile light>
          <!-- Live state -->
          <NsInlineNotification
            v-if="!loading.getConfiguration"
            :kind="server_online ? 'success' : (server_running ? 'warning' : 'info')"
            :title="serverStatusTitle"
            :description="$t('settings.connect_desc', { address })"
            :showCloseButton="false"
            class="info-tile"
          />
          <div v-if="!loading.getConfiguration" class="connect">
            <a :href="'steam://connect/' + address">{{ $t("settings.connect_link", { address }) }}</a>
            <div v-if="!gslt_token_set && !lan_mode" class="bx--form__helper-text">{{ $t("settings.connect_lan_note") }}</div>
          </div>
          <cv-form @submit.prevent="configureModule">
            <!-- Server -->
            <h4 class="section">{{ $t("settings.server_section") }}</h4>
            <cv-text-input :label="$t('settings.server_name')" v-model.trim="server_name" :helper-text="$t('settings.server_name_helper')" :disabled="busy" :invalid-message="$t(error.server_name)" ref="server_name" class="field"></cv-text-input>
            <cv-text-input type="password" :label="$t('settings.server_password')" v-model.trim="server_password" :helper-text="$t('settings.server_password_helper')" :password-hide-label="$t('settings.hide')" :password-show-label="$t('settings.show')" :disabled="busy" :invalid-message="$t(error.server_password)" class="field"></cv-text-input>
            <cv-text-input type="password" :label="$t('settings.gslt_token')" v-model.trim="gslt_token" :placeholder="$t('settings.gslt_token_placeholder')" :helper-text="$t('settings.gslt_token_helper')" :password-hide-label="$t('settings.hide')" :password-show-label="$t('settings.show')" :disabled="busy" class="field"></cv-text-input>
            <div class="bx--form__helper-text">{{ gslt_token_set ? $t("settings.gslt_set") : $t("settings.gslt_not_set") }}</div>
            <cv-toggle v-if="gslt_token_set" value="gslt_clear" :label="$t('settings.gslt_clear')" v-model="gslt_clear" :disabled="busy" class="toggle">
              <template slot="text-left">{{ $t("settings.disabled") }}</template>
              <template slot="text-right">{{ $t("settings.enabled") }}</template>
            </cv-toggle>
            <cv-number-input :label="$t('settings.max_players')" v-model="max_players" :min="1" :max="64" :disabled="busy" class="field"></cv-number-input>
            <cv-number-input :label="$t('settings.game_port')" v-model="game_port" :min="1024" :max="65535" :helper-text="$t('settings.game_port_helper')" :disabled="busy" :invalid-message="$t(error.game_port)" ref="game_port" class="field"></cv-number-input>
            <cv-toggle value="lan_mode" :label="$t('settings.lan_mode')" v-model="lan_mode" :disabled="busy" class="toggle">
              <template slot="text-left">{{ $t("settings.disabled") }}</template>
              <template slot="text-right">{{ $t("settings.enabled") }}</template>
            </cv-toggle>
            <div class="bx--form__helper-text">{{ $t("settings.lan_mode_helper") }}</div>

            <!-- Game -->
            <h4 class="section">{{ $t("settings.game_section") }}</h4>
            <cv-dropdown :label="$t('settings.game_mode')" v-model="game_mode" :disabled="busy" class="field">
              <cv-dropdown-item value="competitive">{{ $t("settings.mode_competitive") }}</cv-dropdown-item>
              <cv-dropdown-item value="casual">{{ $t("settings.mode_casual") }}</cv-dropdown-item>
              <cv-dropdown-item value="wingman">{{ $t("settings.mode_wingman") }}</cv-dropdown-item>
              <cv-dropdown-item value="deathmatch">{{ $t("settings.mode_deathmatch") }}</cv-dropdown-item>
              <cv-dropdown-item value="armsrace">{{ $t("settings.mode_armsrace") }}</cv-dropdown-item>
              <cv-dropdown-item value="demolition">{{ $t("settings.mode_demolition") }}</cv-dropdown-item>
              <cv-dropdown-item value="custom">{{ $t("settings.mode_custom") }}</cv-dropdown-item>
            </cv-dropdown>
            <cv-text-input :label="$t('settings.map_group')" v-model.trim="map_group" :helper-text="$t('settings.map_group_helper')" :disabled="busy" :invalid-message="$t(error.map_group)" ref="map_group" class="field"></cv-text-input>
            <cv-text-input :label="$t('settings.start_map')" v-model.trim="start_map" :helper-text="$t('settings.start_map_helper')" :disabled="busy" :invalid-message="$t(error.start_map)" ref="start_map" class="field"></cv-text-input>
            <cv-text-input :label="$t('settings.workshop_collection')" v-model.trim="workshop_collection" :helper-text="$t('settings.workshop_collection_helper')" :disabled="busy" :invalid-message="$t(error.workshop_collection)" ref="workshop_collection" class="field"></cv-text-input>
            <cv-text-input :label="$t('settings.workshop_map')" v-model.trim="workshop_map" :helper-text="$t('settings.workshop_map_helper')" :disabled="busy" :invalid-message="$t(error.workshop_map)" ref="workshop_map" class="field"></cv-text-input>

            <!-- Bots -->
            <h4 class="section">{{ $t("settings.bots_section") }}</h4>
            <cv-number-input :label="$t('settings.bot_quota')" v-model="bot_quota" :min="0" :max="64" :helper-text="$t('settings.bot_quota_helper')" :disabled="busy" class="field"></cv-number-input>
            <cv-dropdown :label="$t('settings.bot_difficulty')" v-model="bot_difficulty" :disabled="busy" class="field">
              <cv-dropdown-item value="0">{{ $t("settings.bot_0") }}</cv-dropdown-item>
              <cv-dropdown-item value="1">{{ $t("settings.bot_1") }}</cv-dropdown-item>
              <cv-dropdown-item value="2">{{ $t("settings.bot_2") }}</cv-dropdown-item>
              <cv-dropdown-item value="3">{{ $t("settings.bot_3") }}</cv-dropdown-item>
            </cv-dropdown>
            <cv-dropdown :label="$t('settings.bot_quota_mode')" v-model="bot_quota_mode" :disabled="busy" class="field">
              <cv-dropdown-item value="fill">{{ $t("settings.bqm_fill") }}</cv-dropdown-item>
              <cv-dropdown-item value="competitive">{{ $t("settings.bqm_competitive") }}</cv-dropdown-item>
              <cv-dropdown-item value="normal">{{ $t("settings.bqm_normal") }}</cv-dropdown-item>
            </cv-dropdown>

            <!-- CSTV -->
            <h4 class="section">{{ $t("settings.tv_section") }}</h4>
            <cv-toggle value="tv_enabled" :label="$t('settings.tv_enabled')" v-model="tv_enabled" :disabled="busy" class="toggle">
              <template slot="text-left">{{ $t("settings.disabled") }}</template>
              <template slot="text-right">{{ $t("settings.enabled") }}</template>
            </cv-toggle>
            <template v-if="tv_enabled">
              <cv-number-input :label="$t('settings.tv_port')" v-model="tv_port" :min="1024" :max="65535" :disabled="busy" :invalid-message="$t(error.tv_port)" ref="tv_port" class="field"></cv-number-input>
              <cv-text-input type="password" :label="$t('settings.tv_password')" v-model.trim="tv_password" :password-hide-label="$t('settings.hide')" :password-show-label="$t('settings.show')" :disabled="busy" :invalid-message="$t(error.tv_password)" class="field"></cv-text-input>
              <cv-number-input :label="$t('settings.tv_delay')" v-model="tv_delay" :min="0" :max="3600" :disabled="busy" class="field"></cv-number-input>
              <cv-toggle value="tv_autorecord" :label="$t('settings.tv_autorecord')" v-model="tv_autorecord" :disabled="busy" class="toggle">
                <template slot="text-left">{{ $t("settings.disabled") }}</template>
                <template slot="text-right">{{ $t("settings.enabled") }}</template>
              </cv-toggle>
            </template>

            <!-- Advanced -->
            <h4 class="section">{{ $t("settings.advanced_section") }}</h4>
            <cv-toggle value="validate_files" :label="$t('settings.validate_files')" v-model="validate_files" :disabled="busy" class="toggle">
              <template slot="text-left">{{ $t("settings.disabled") }}</template>
              <template slot="text-right">{{ $t("settings.enabled") }}</template>
            </cv-toggle>
            <div class="bx--form__helper-text">{{ $t("settings.validate_files_helper") }}</div>
            <cv-text-input :label="$t('settings.additional_args')" v-model.trim="additional_args" :placeholder="$t('settings.additional_args_placeholder')" :helper-text="$t('settings.additional_args_helper')" :disabled="busy" class="field"></cv-text-input>
            <cv-text-area :label="$t('settings.extra_env')" v-model="extra_env_text" :placeholder="$t('settings.extra_env_placeholder')" :helper-text="$t('settings.extra_env_helper')" :disabled="busy" :invalid-message="$t(error.extra_env)" ref="extra_env" rows="4" class="field"></cv-text-area>

            <cv-row v-if="error.configureModule">
              <cv-column>
                <NsInlineNotification kind="error" :title="$t('action.configure-module')" :description="error.configureModule" :showCloseButton="false" />
              </cv-column>
            </cv-row>
            <NsButton kind="primary" :icon="Save20" :loading="loading.configureModule" :disabled="busy">{{ $t("settings.save") }}</NsButton>
          </cv-form>
        </cv-tile>
      </cv-column>
    </cv-row>

    <!-- Server console -->
    <cv-row>
      <cv-column>
        <cv-tile light>
          <h4 class="section-first">{{ $t("settings.command_section") }}</h4>
          <cv-form @submit.prevent="runCommand">
            <cv-text-input :label="$t('settings.command')" v-model.trim="command" :placeholder="$t('settings.command_placeholder')" :helper-text="$t('settings.command_helper')" :disabled="loading.runCommand || !server_online" class="field"></cv-text-input>
            <NsButton kind="secondary" :icon="Send20" :loading="loading.runCommand" :disabled="loading.runCommand || !server_online || !command">{{ $t("settings.run_command") }}</NsButton>
          </cv-form>
          <NsInlineNotification v-if="error.runCommand" kind="error" :title="$t('action.run-command')" :description="error.runCommand" :showCloseButton="false" class="info-tile" />
          <div v-if="command_output !== null" class="field">
            <div class="bx--label">{{ $t("settings.command_output") }}</div>
            <pre class="console">{{ command_output || $t("settings.command_no_output") }}</pre>
          </div>
        </cv-tile>
      </cv-column>
    </cv-row>
  </cv-grid>
</template>

<script>
import to from "await-to-js";
import { mapState } from "vuex";
import { QueryParamService, UtilService, TaskService, IconService, PageTitleService } from "@nethserver/ns8-ui-lib";
import Send20 from "@carbon/icons-vue/es/send/20";

const MAP_RE = /^[A-Za-z0-9_]*$/;
const ID_RE = /^[0-9]*$/;
const ENV_RE = /^[A-Z][A-Z0-9_]*=/;

export default {
  name: "Settings",
  mixins: [TaskService, IconService, UtilService, QueryParamService, PageTitleService],
  pageTitle() {
    return this.$t("settings.title") + " - " + this.appName;
  },
  data() {
    return {
      q: { page: "settings" },
      urlCheckInterval: null,
      Send20,
      server_name: "",
      server_password: "",
      gslt_token: "",
      gslt_token_set: false,
      gslt_clear: false,
      max_players: 10,
      game_port: 27015,
      lan_mode: false,
      game_mode: "competitive",
      map_group: "mg_active",
      start_map: "de_inferno",
      workshop_collection: "",
      workshop_map: "",
      bot_difficulty: "1",
      bot_quota: 0,
      bot_quota_mode: "fill",
      tv_enabled: false,
      tv_port: 27020,
      tv_password: "",
      tv_delay: 0,
      tv_autorecord: false,
      validate_files: false,
      additional_args: "",
      extra_env_text: "",
      server_running: false,
      server_online: false,
      server_version: "",
      current_map: "",
      players_online: null,
      players_max: null,
      bots_online: null,
      node_ip: "",
      command: "",
      command_output: null,
      loading: { getConfiguration: false, configureModule: false, runCommand: false },
      error: {
        getConfiguration: "", configureModule: "", runCommand: "",
        server_name: "", server_password: "", game_port: "", map_group: "", start_map: "", workshop_collection: "", workshop_map: "", tv_port: "", tv_password: "", extra_env: "",
      },
    };
  },
  computed: {
    ...mapState(["instanceName", "core", "appName"]),
    busy() {
      return this.loading.getConfiguration || this.loading.configureModule;
    },
    extra_env() {
      return this.extra_env_text.split(/\r?\n/).map((p) => p.trim()).filter((p) => p.length > 0);
    },
    address() {
      return `${this.node_ip || "<node>"}:${this.game_port}`;
    },
    serverStatusTitle() {
      if (!this.server_running) return this.$t("settings.status_stopped");
      if (!this.server_online) return this.$t("settings.status_starting");
      return this.$t("settings.status_online", { version: this.server_version, map: this.current_map, online: this.players_online, max: this.players_max, bots: this.bots_online });
    },
  },
  beforeRouteEnter(to, from, next) {
    next((vm) => {
      vm.watchQueryData(vm);
      vm.urlCheckInterval = vm.initUrlBindingForApp(vm, vm.q.page);
    });
  },
  beforeRouteLeave(to, from, next) {
    clearInterval(this.urlCheckInterval);
    next();
  },
  created() {
    this.getConfiguration();
  },
  methods: {
    async getConfiguration() {
      this.loading.getConfiguration = true;
      this.error.getConfiguration = "";
      const taskAction = "get-configuration";
      const eventId = this.getUuid();
      this.core.$root.$once(`${taskAction}-aborted-${eventId}`, this.getConfigurationAborted);
      this.core.$root.$once(`${taskAction}-completed-${eventId}`, this.getConfigurationCompleted);
      const res = await to(this.createModuleTaskForApp(this.instanceName, { action: taskAction, extra: { title: this.$t("action." + taskAction), isNotificationHidden: true, eventId } }));
      const err = res[0];
      if (err) {
        this.error.getConfiguration = this.getErrorMessage(err);
        this.loading.getConfiguration = false;
      }
    },
    getConfigurationAborted(taskResult, taskContext) {
      console.error(`${taskContext.action} aborted`, taskResult);
      this.error.getConfiguration = this.$t("error.generic_error");
      this.loading.getConfiguration = false;
    },
    getConfigurationCompleted(taskContext, taskResult) {
      this.loading.getConfiguration = false;
      const c = taskResult.output;
      this.server_name = c.server_name || "";
      this.server_password = c.server_password || "";
      this.gslt_token = "";
      this.gslt_token_set = !!c.gslt_token_set;
      this.gslt_clear = false;
      this.max_players = c.max_players || 10;
      this.game_port = c.game_port || 27015;
      this.lan_mode = !!c.lan_mode;
      this.game_mode = c.game_mode || "competitive";
      this.map_group = c.map_group || "mg_active";
      this.start_map = c.start_map || "de_inferno";
      this.workshop_collection = c.workshop_collection || "";
      this.workshop_map = c.workshop_map || "";
      this.bot_difficulty = String(c.bot_difficulty !== undefined ? c.bot_difficulty : 1);
      this.bot_quota = c.bot_quota || 0;
      this.bot_quota_mode = c.bot_quota_mode || "fill";
      this.tv_enabled = !!c.tv_enabled;
      this.tv_port = c.tv_port || 27020;
      this.tv_password = c.tv_password || "";
      this.tv_delay = c.tv_delay || 0;
      this.tv_autorecord = !!c.tv_autorecord;
      this.validate_files = !!c.validate_files;
      this.additional_args = c.additional_args || "";
      this.extra_env_text = (c.extra_env || []).join("\n");
      this.server_running = !!c.server_running;
      this.server_online = !!c.server_online;
      this.server_version = c.server_version || "";
      this.current_map = c.current_map || "";
      this.players_online = c.players_online;
      this.players_max = c.players_max;
      this.bots_online = c.bots_online;
      this.node_ip = c.node_ip || "";
    },
    validateConfigureModule() {
      this.clearErrors(this);
      let ok = true;
      const fail = (field, msg) => {
        this.error[field] = msg;
        if (ok && this.$refs[field]) this.focusElement(field);
        ok = false;
      };
      if (!this.server_name) fail("server_name", "common.required");
      for (const f of ["server_name", "server_password", "tv_password"]) {
        if (/["\n]/.test(this[f])) fail(f, "settings.invalid_characters");
      }
      if (!MAP_RE.test(this.map_group)) fail("map_group", "settings.invalid_map_name");
      if (!MAP_RE.test(this.start_map)) fail("start_map", "settings.invalid_map_name");
      if (!ID_RE.test(this.workshop_collection)) fail("workshop_collection", "settings.invalid_workshop_id");
      if (!ID_RE.test(this.workshop_map)) fail("workshop_map", "settings.invalid_workshop_id");
      if (this.tv_enabled && Number(this.tv_port) === Number(this.game_port)) fail("tv_port", "settings.port_same_as_game_port");
      if (this.extra_env.some((e) => !ENV_RE.test(e))) fail("extra_env", "settings.invalid_extra_env");
      return ok;
    },
    configureModuleValidationFailed(validationErrors) {
      this.loading.configureModule = false;
      let focusSet = false;
      for (const e of validationErrors) {
        if (e.field !== "(root)") {
          const detail = e.value && typeof e.value === "string" ? ` (${e.value})` : "";
          this.error[e.field] = this.$t("settings." + e.error) + detail;
          if (!focusSet && this.$refs[e.field]) {
            this.focusElement(e.field);
            focusSet = true;
          }
        }
      }
    },
    async configureModule() {
      if (!this.validateConfigureModule()) return;
      this.loading.configureModule = true;
      const taskAction = "configure-module";
      const eventId = this.getUuid();
      this.core.$root.$once(`${taskAction}-aborted-${eventId}`, this.configureModuleAborted);
      this.core.$root.$once(`${taskAction}-validation-failed-${eventId}`, this.configureModuleValidationFailed);
      this.core.$root.$once(`${taskAction}-completed-${eventId}`, this.configureModuleCompleted);
      const data = {
        server_name: this.server_name,
        server_password: this.server_password,
        gslt_token: this.gslt_token,
        gslt_clear: this.gslt_clear,
        max_players: Number(this.max_players),
        game_port: Number(this.game_port),
        lan_mode: this.lan_mode,
        game_mode: this.game_mode,
        map_group: this.map_group,
        start_map: this.start_map,
        workshop_collection: this.workshop_collection,
        workshop_map: this.workshop_map,
        bot_difficulty: Number(this.bot_difficulty),
        bot_quota: Number(this.bot_quota),
        bot_quota_mode: this.bot_quota_mode,
        tv_enabled: this.tv_enabled,
        tv_port: Number(this.tv_port),
        tv_password: this.tv_password,
        tv_delay: Number(this.tv_delay),
        tv_autorecord: this.tv_autorecord,
        validate_files: this.validate_files,
        additional_args: this.additional_args,
        extra_env: this.extra_env,
      };
      const res = await to(this.createModuleTaskForApp(this.instanceName, {
        action: taskAction,
        data,
        extra: { title: this.$t("settings.configure_instance", { instance: this.instanceName }), description: this.$t("common.processing"), eventId },
      }));
      const err = res[0];
      if (err) {
        this.error.configureModule = this.getErrorMessage(err);
        this.loading.configureModule = false;
      }
    },
    configureModuleAborted(taskResult, taskContext) {
      console.error(`${taskContext.action} aborted`, taskResult);
      this.error.configureModule = this.$t("error.generic_error");
      this.loading.configureModule = false;
    },
    configureModuleCompleted() {
      this.loading.configureModule = false;
      this.getConfiguration();
    },
    async runCommand() {
      if (!this.command) return;
      this.loading.runCommand = true;
      this.error.runCommand = "";
      this.command_output = null;
      const taskAction = "run-command";
      const eventId = this.getUuid();
      this.core.$root.$once(`${taskAction}-aborted-${eventId}`, this.runCommandAborted);
      this.core.$root.$once(`${taskAction}-completed-${eventId}`, this.runCommandCompleted);
      const res = await to(this.createModuleTaskForApp(this.instanceName, {
        action: taskAction,
        data: { command: this.command },
        extra: { title: this.$t("action." + taskAction), isNotificationHidden: true, eventId },
      }));
      const err = res[0];
      if (err) {
        this.error.runCommand = this.getErrorMessage(err);
        this.loading.runCommand = false;
      }
    },
    runCommandAborted(taskResult, taskContext) {
      console.error(`${taskContext.action} aborted`, taskResult);
      this.error.runCommand = this.$t("error.generic_error");
      this.loading.runCommand = false;
    },
    runCommandCompleted(taskContext, taskResult) {
      this.loading.runCommand = false;
      this.command_output = (taskResult.output && taskResult.output.output) || "";
      this.getConfiguration();
    },
  },
};
</script>

<style scoped lang="scss">
@import "../styles/carbon-utils";
.field { margin-top: $spacing-06; }
.toggle { margin-top: $spacing-06; }
.info-tile { margin-top: $spacing-06; }
.connect { margin-top: $spacing-04; }
.section { margin-top: $spacing-07; margin-bottom: $spacing-03; }
.section-first { margin-bottom: $spacing-03; }
.console { font-family: monospace; white-space: pre-wrap; background: #f4f4f4; padding: $spacing-05; margin-top: $spacing-03; }
</style>
