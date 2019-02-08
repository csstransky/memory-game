import React from 'react';
import ReactDOM from 'react-dom';
import _ from 'lodash';

export default function game_init(root, channel) {
  ReactDOM.render(<Memory channel={channel} />, root);
}

class Memory extends React.Component {
  constructor(props) {
    super(props);

		this.channel = props.channel;
		this.state = {
      panel_list: [{ value: "Loading", hidden: false }],
      compare_string: "",
      score: 0,
    };
		this.channel.join()
			.receive("ok", resp => {
				console.log("Joined successfully5", resp);
        this.setState(resp.game);
        console.log("new view", resp);
			})
			.receive("error", resp => {
				console.log("Unable to join", resp);
			});
  }

	flip(clicked_panel_index, _ev) {
    if (this.state.compare_string != "LOCK") {
      this.channel.push("flip", { panel_index: clicked_panel_index })
  			.receive("ok", resp => { this.setState(resp.game); });
      window.setTimeout(function () {
        this.channel.push("flip_back")
          .receive("ok", resp => { this.setState(resp.game); });
      }.bind(this), 1000);
    }
    // Speeds up and unlocks the game right away
    else {
      this.channel.push("flip_back")
        .receive("ok", resp => { this.setState(resp.game); });
    }
	}

 	reset() {
		this.channel.push("reset").receive("ok", resp => {
			this.setState(resp.game);
		});
	}

  render() {
		let gameboard = _.map(
			_.chunk(this.state.panel_list, 4), (rowOfTiles, rowNum) => {
				return <div className="row" key={rowNum}>{
						_.map(rowOfTiles, (panel, colNum) => {
							let ll = rowNum * 4 + colNum;
							return <div className="column" key={ll}>
								<div className="panel"
										 onClick={this.flip.bind(this, ll)}>
								<RenderPanel value={panel.value}
														 hidden={panel.hidden} />
								</div>
							</div>;
							})
						}</div>
				});

		return <div>SCORE: {this.state.score}
				{gameboard}
				<p><button onClick={this.reset.bind(this)}>Restart</button></p>
			</div>;
  }
}

function RenderPanel({value, hidden}) {
	if (hidden) {
		return <p></p>;
	}
	else {
		return <p>{value}</p>;
	}
}
