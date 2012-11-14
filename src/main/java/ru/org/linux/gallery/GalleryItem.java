/*
 * Copyright 1998-2012 Linux.org.ru
 *    Licensed under the Apache License, Version 2.0 (the "License");
 *    you may not use this file except in compliance with the License.
 *    You may obtain a copy of the License at
 *
 *        http://www.apache.org/licenses/LICENSE-2.0
 *
 *    Unless required by applicable law or agreed to in writing, software
 *    distributed under the License is distributed on an "AS IS" BASIS,
 *    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *    See the License for the specific language governing permissions and
 *    limitations under the License.
 */

package ru.org.linux.gallery;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import ru.org.linux.util.ImageInfo;

public class GalleryItem {
  private static final Log log = LogFactory.getLog(GalleryItem.class);

  private Integer msgid;
  private String nick;
  private String icon;
  private ImageInfo info;
  private ImageInfo imginfo;
  private String title;
  private Integer stat;
  private String url;
  private String link;

  public String getLink() {
    return link;
  }

  public void setLink(String link) {
    this.link = link;
  }

  public Integer getMsgid() {
    return msgid;
  }

  public void setMsgid(Integer msgid) {
    this.msgid = msgid;
  }

  public String getNick() {
    return nick;
  }

  public void setNick(String nick) {
    this.nick = nick;
  }

  public String getIcon() {
    return icon;
  }

  public void setIcon(String icon) {
    this.icon = icon;
  }

  public ImageInfo getInfo() {
    return info;
  }

  public void setInfo(ImageInfo info) {
    this.info = info;
  }

  public ImageInfo getImginfo() {
    return imginfo;
  }

  public void setImginfo(ImageInfo imginfo) {
    this.imginfo = imginfo;
  }

  public String getTitle() {
    return title;
  }

  public void setTitle(String title) {
    this.title = title;
  }

  public Integer getStat() {
    return stat;
  }

  public void setStat(Integer stat) {
    this.stat = stat;
  }

  public String getUrl() {
    return url;
  }

  public void setUrl(String url) {
    this.url = url;
  }
}
