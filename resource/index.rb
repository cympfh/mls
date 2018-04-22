require 'set'
require 'erb'

def cat(filename)
  open(__dir__ + "/" + filename).read
end

def normalize(tag)
  tag.gsub('/', '_').gsub(' ', '_')
end

def num_of_cid(cid)
  cid.gsub(/^[a-z]*/, '')
end

def shorten(tag)
  # AA/bb/ccc => A/b/ccc
  xs = tag.split('/')
  xs.map.with_index {|t, i|
    i < xs.size - 1 ? t[0] : t}.join('/')
end

tagset = Set.new
videos = {}

open(ARGV[0]).each_line do |line|
  type, cid, title, tags = line.chomp.split("\t")
  tags = tags.split(",")
  tags.each {|t|
    tagset << t
    videos[t] = [] if videos[t] == nil
    videos[t] << [type, cid, title, tags]
  }
end

tagset = tagset.to_a.sort

def csstrick(tag)
<<EOM
##{normalize tag}:target { display: block }
##{normalize tag}:not(target) { display: none }
EOM
end

contents = <<EOS
<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8">
        <title>mls</title>
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/bulma/0.6.0/css/bulma.min.css">
        <link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/font-awesome/4.7.0/css/font-awesome.min.css">
        <style>
<%= cat "css/base.css" %>
<% tagset.each do |tag| %><%= csstrick(tag) %><% end %>
        </style>
    </head>
    <body>


        <!-- BEGIN tag list -->

        <section class="hero">
            <div class="hero-body">
                <div class="container">
<% tagset.each do |tag| %>
            <a class="button" href=#<%= normalize tag %>><%= shorten tag %></a>
<% end %>
                </div>
            </div>
        </section>
        <!-- END tag list -->


        <!-- BEGIN tag videos -->
<% tagset.each do |tag| %>
        <div class="tagitem" id="<%= normalize tag %>">
            <h1 class=title><%= tag %></h1>

            <% videos[tag].each do |video| %>

                <div class="box">
                    <article class="media">
                        <div class="media-left">

                            <% if video[0] == "Y" %>
                            <img src="https://i.ytimg.com/vi/<%= video[1] %>/mqdefault.jpg" width="130px" />
                            <% elsif video[0] == "N" %>
                            <img src="http://tn.smilevideo.jp/smile?i=<%= num_of_cid(video[1]) %>">
                            <% end %>

                        </div>
                        <div class="media-content">
                            <div class="content">
                                <p>

                                <% if video[0] == "Y" %>
                                <a href="https://www.youtube.com/watch?v=<%= video[1] %>"><%= video[2] %></a>
                                <% elsif video[0] == "N" %>
                                <a href="http://www.nicovideo.jp/watch/<%= video[1] %>"><%= video[2] %></a>
                                <% end %>

                                <a href="javascript:play('<%= video[0] %>', '<%= video[1] %>')" class="button is-small"><i class="fa fa-crop"></i></a>
                                </p>
                                <div class="tags">

                                <% video[3].each do |tag| %>
                                    <a class=tag href=#<%= normalize tag %>><%= tag %></a>
                                <% end %>

                                </div>
                            </div>
                        </div>
                    </article>
                </div>

            <% end %>

        </div>
<% end %>
        <!-- END tag videos -->

        <%= cat "player.html" %>
    </body>
</html>
EOS

ERB.new(contents, nil, 1).run
