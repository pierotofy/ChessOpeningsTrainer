<template>
  <v-container :class="{'hide': !active}" class="tab">
    <v-app-bar
      app
      color="primary"
      dark
    >
    </v-app-bar>

    <iframe class="board" :src="boardUrl"></iframe>
  </v-container>
</template>

<script>
  export default {
    props: ["active", "mode"],
    data: () => ({
      
    }),
    computed: {
      boardUrl: function(){
        const base = "/board/index.html";
        const params = {
          mode: this.mode
        };

        if (this.mode === "tree" || this.mode === "treetrain"){
          params.maxTreeMoves = 5; // TODO
        }

        return `${base}?${Object.keys(params).map(k => k + '=' + params[k]).join('&')}`;
      }
    },
    watch: {
      active: function(){
        // TODO load
      }
    }
  }
</script>
