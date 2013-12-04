class LinesController < ApplicationController
  # GET /lines
  # GET /lines.json
  def index
    @lines = Line.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @lines }
    end
  end

  # GET /lines/1
  # GET /lines/1.json
  def show
    @line = Line.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @line }
    end
  end

  # GET /lines/new
  # GET /lines/new.json
  def new
    @line = Line.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @line }
    end
  end

  # GET /lines/1/edit
  def edit
    @line = Line.find(params[:id])
  end

  # POST /lines
  # POST /lines.json
  def create
    @line = Line.new(params[:line])

    respond_to do |format|
      if @line.save
        #rmq_create_line(@line)
        format.html { redirect_to @line, notice: 'Line was successfully created.' }
        format.json { render json: @line, status: :created, location: @line }
        format.js { render :js => "emit_message(#{@line.room_id}, [#{@line.to_json}, #{@line.user.to_json}]);" }
        #format.js { render :js => "emit_message(#{@line.room_id}, #{@line});" }
        #format.js { render  status: 200 }
      else
        format.html { render action: "new" }
        format.json { render json: @line.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /lines/1
  # PUT /lines/1.json
  def update
    @line = Line.find(params[:id])

    respond_to do |format|
      if @line.update_attributes(params[:line])
        format.html { redirect_to @line, notice: 'Line was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @line.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /lines/1
  # DELETE /lines/1.json
  def destroy
    @line = Line.find(params[:id])
    @room_id = @line.room_id
    @line_id = @line.id
    @line.destroy

    #rmq_destroy_line(@line.id)

    respond_to do |format|
      format.html { redirect_to lines_url }
      format.json { head :no_content }
      format.js { render :js => "emit_message_destroy(#{@room_id}, #{@line_id});" }
    end
  end

  def rmq_create_line(msg)
    EventMachine.run do
      connection = AMQP.connect(:host => '127.0.0.1')
      #puts "Connecting to RabbitMQ. Running #{AMQP::VERSION} version of the gem..."

      ch  = AMQP::Channel.new(connection)
      q   = ch.queue('create_line', :auto_delete => true)
      x   = ch.default_exchange

      q.subscribe do |metadata, payload|
        puts "Received a message: #{payload}. Disconnecting..."


        connection.close {
          EventMachine.stop { exit }
        }
      end
      x.publish [msg.room_id, msg], :routing_key => q.name
    end
=begin
    response = [msg, msg.user]
    conn = Bunny.new
    conn.start

    ch = conn.create_channel
    x = ch.direct('create_line')
    x.publish(response.to_json, :routing_key => "room_#{msg.room_id}")

    conn.close
=end

=begin
    AMQP.start(:host => 'localhost') do |connection|
      AMQP::Channel.new(connection).fanout('create_message').publish(msg)

      EM.add_timer(0.5) do
        connection.close do
          EM.stop {exit}
        end
      end
    end
=end
  end

  def rmq_destroy_line(id)
    AMQP.start(:host => 'localhost') do |connection|
      AMQP::Channel.new(connection).fanout('destroy_message').publish(id)

      EM.add_timer(0.5) do
        connection.close do
          EM.stop {exit}
        end
      end
    end
  end

end
