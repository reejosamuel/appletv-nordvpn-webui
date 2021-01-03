class Response
    def self.output_speech(session_id, speech) 
        output = <<-RESP
        {
            "session": {
                "id": "example_session_id",
                "params": {}
            },
            "prompt": {
                "override": false,
                "firstSimple": {
                    "speech": "Hello World.",
                    "text": ""
                }
            },
            "scene": {
                "name": "SceneName",
                "slots": {},
                "next": {
                "name": "actions.scene.END_CONVERSATION"
                }
            }
        }
        RESP

        resp = JSON.parse output
        resp["session"]["id"] = session_id
        resp["prompt"]["firstSimple"]["speech"] = speech
        resp["prompt"]["firstSimple"]["text"] = speech
        resp.to_json
    end
end