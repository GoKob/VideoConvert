<template>
  <div class="home">
    <div class="container">
        <div class="row">
          <video id="video-player" class="mt-3 col-lg-6 col-12"
            autoPlay
            controls
            playsinline
          />
          
          <div class="col-lg-6">
            <div class="row">
              <div class="input-group mb-3 mt-3 col-12">
                <input type="text" v-model="date" class="form-control" placeholder="Please set datetime" aria-label="Load" aria-describedby="Load" required>
                <button class="btn btn-secondary" type="button" id="Load" v-on:click="setplayer">Load</button>
              </div>
              
              <div class="input-group mb-3 col-12">
                <input type="text" v-model="start" class="form-control" placeholder="StartPoint" aria-label="StartPoint" aria-describedby="StartTime" readonly required>
                <button class="btn btn-primary" type="button" id="start" v-on:click="getCurrentTime">Start</button>
              </div>
              
              <div class="input-group mb-3 col-12">
                <input type="text" v-model="end" class="form-control" placeholder="EndPoint" aria-label="EndPoint" aria-describedby="EndTime" readonly required>
                <button class="btn btn-success" type="button" id="end" v-on:click="getCurrentTime">End</button>
              </div>
              
              <div class="input-group mb-3 col-12">
                <input type="text" v-model="folder" class="form-control" placeholder="upload folder name" aria-label="folder" aria-describedby="folder" required>
              </div>
            </div>
          </div>
        </div>

        <div class="d-grid mt-4 mb-4">
          <button v-bind:class="[activateSubmit == true ? 'btn btn-outline-dark': 'btn btn-dark']" v-bind:disabled="activateSubmit" type="button" data-bs-toggle="modal" data-bs-target="#Modal" v-on:click="requestConvert" >Convert</button>
        </div>
      </div>

    <div class="modal fade" id="Modal" tabindex="-1" aria-labelledby="ModalLabel" aria-hidden="true">
      <div class="modal-dialog">
        <div class="modal-content">
          <div class="modal-header">
            <h5 class="modal-title" id="exampleModalLabel">Request Convert</h5>
            <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
          </div>
          <div class="modal-body">
            切り出しをリクエストしました。結果は Google Drive で確認してください
          </div>
          <div class="modal-footer">
            <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Close</button>
          </div>
        </div>
      </div>
    </div>
    
  </div>
  
</template>

<script>
import { API, Amplify } from 'aws-amplify';
import awsconfig from '../aws-exports';
Amplify.configure(awsconfig);


const player = IVSPlayer.create();

export default {
  props: {
    username: String,
  },
  data(){
    return{
      url: "xxxxxxxxx",
      date: null,
      start: null,
      end: null,
      folder: null
    }
  },
  computed: {
    activateSubmit() {
      if (this.start == null) {
        return true;
      } else if (this.end == null ) {
        return true;
      } else if (this.folder == null || this.folder == "") {
        return true;
      } else {
        return false;
      }
    }
  },
  methods: {
    setplayer: function() {
      player.attachHTMLVideoElement(document.getElementById('video-player'));
      player.load(this.url + "?start=" + this.date);
      player.play();
    },
    getCurrentTime: function(e) {
      console.log(player.core.state.position);
    
      const target = new Date(this.date);
      target.setSeconds(target.getSeconds() + parseInt(player.core.state.position, 10));
      this[e.target.id] = this.toISOString(target);
      
    },
    toISOString: function(date) {
      const month = date.getMonth() + 1;
      
      return date.getFullYear() +
        '-' + ("0"+month).slice(-2) +
        '-' + ("0"+date.getDate()).slice(-2) +
        'T' + ("0"+date.getHours()).slice(-2) +
        ':' + ("0"+date.getMinutes()).slice(-2) +
        ':' + ("0"+date.getSeconds()).slice(-2) + "+09:00";
    },
    requestConvert: async function () {
      const request = {
        headers: {
          "Content-Type": "application/json",
        },
        body: {
          "start": this.start,
          "end": this.end,
          "folder": this.folder
        }
      }
      const createResult = await API.post('requestconvert', '/req', request)
      console.log(createResult);
    }
    
  }
};
</script>
