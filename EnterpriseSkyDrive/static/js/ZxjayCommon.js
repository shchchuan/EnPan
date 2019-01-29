//


function $(divID)
{
    return document.getElementById(divID);
}

String.prototype.trim = function()
{
    return this.replace(/(^\s*)|(\s*$)/g, "");
}

var createImg = function()
{
    return document.createElement("img");
}

var createDiv = function()
{
    return document.createElement("div");
}

var createBtn = function()
{
    var btn = document.createElement("input");
    btn.type = "button";
    return btn;
}

var createSpan = function()
{
    return document.createElement("span");
}