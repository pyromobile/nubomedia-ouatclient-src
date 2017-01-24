'use-strict';

import React,{Component} from 'react';

export default class TaleCmp extends Component
{
  constructor( props )
  {
    super(props);
  }

  render()
  {
    let index=0;
    let images = this.props.pageToShow.storyImagesPath.map(function(storyImagePath){
      let name = ( index == this.props.pageToShow.fadeInImagePos ) ? 'opaque':'';
      return(<img key={++index} style={{border:'1px solid black'}} src={storyImagePath} className={name}></img>);
    },this);
    return(
      <div className='mainContent'>
        <div id="view2">
          {images}
        </div>
        <div className="bottom">
          <div id="storyText" className="storyText">
            <span>{this.props.pageToShow.text}</span>
            <a className="arrow prev" href="#" onClick={e=>{this.prevPage(e)}}></a>
            <a className="arrow next" href="#" onClick={e=>{this.nextPage(e)}}></a>
          </div>
        </div>
      </div>
    );
  }

  prevPage(e)
  {
    e.preventDefault();
    this.props.pageNavigator.prevPage();
  }

  nextPage(e)
  {
    e.preventDefault();
    this.props.pageNavigator.nextPage();
  }
}
