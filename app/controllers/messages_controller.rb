require 'amqp'

class MessagesController < ApplicationController
  # GET /messages
  # GET /messages.json
  def index
    @messages = Message.order('created_at ASC')
    #listen_rabbit

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @messages }
    end
  end

  # GET /messages/1
  # GET /messages/1.json
  def show
    @message = Message.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @message }
    end
  end

  # GET /messages/new
  # GET /messages/new.json
  def new
    @message = Message.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @message }
    end
  end

  # GET /messages/1/edit
  def edit
    @message = Message.find(params[:id])
  end

  # POST /messages
  # POST /messages.json
  def create
    @message = Message.new(params[:message])

    respond_to do |format|
      if @message.save
        user = @message.user
        rmq_create([@message, user].to_json)
        format.html { redirect_to @message, notice: 'Message was successfully created.' }
        format.json { render json: @message, status: :created, location: @message }
        format.js { render :js => '' }
      else
        format.html { render action: "new" }
        format.json { render json: @message.errors, status: :unprocessable_entity }
        format.js { render :js => 'alert("Mensaje vacio");' }
      end
    end
  end

  # PUT /messages/1
  # PUT /messages/1.json
  def update
    @message = Message.find(params[:id])

    respond_to do |format|
      if @message.update_attributes(params[:message])
        format.html { redirect_to @message, notice: 'Message was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @message.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /messages/1
  # DELETE /messages/1.json
  def destroy
    @message = Message.find(params[:id])
    id = @message.id
    @message.destroy
    rmq_destroy(id)

    respond_to do |format|
      format.html { render nothing: true }
      format.json { head :no_content }
      format.js { render :js => '' }
    end
  end

  def prueba
    @messages = Message.limit(5)

    respond_to do |format|
      format.html { render 'test' }
    end
  end

  def rmq_create(msg)
    AMQP.start(:host => 'localhost') do |connection|
      AMQP::Channel.new(connection).fanout('create_message').publish(msg)

      EM.add_timer(0.5) do
        connection.close do
          EM.stop {exit}
        end
      end
    end
  end

  def rmq_destroy(id)
    AMQP.start(:host => 'localhost') do |connection|
      AMQP::Channel.new(connection).fanout('destroy_message').publish(id)

      EM.add_timer(0.5) do
        connection.close do
          EM.stop {exit}
        end
      end
    end
  end

  def client
    EventMachine.run do
      connection = AMQP.connect(:host => '127.0.0.1')
      puts "Connecting to RabbitMQ. Running #{AMQP::VERSION} version of the gem..."

      ch  = AMQP::Channel.new(connection)
      q   = ch.queue('create_message', :auto_delete => true)
      x   = ch.default_exchange

      q.subscribe do |metadata, payload|
        puts "Received a message: #{payload}. Disconnecting..."

        connection.close {
          EventMachine.stop { exit }
        }
      end

      x.publish "Hello, world!", :routing_key => q.name
    end

  end

=begin
  def listen_rabbit
    Thread.new do

        begin
          AMQP.start(:host => 'localhost') do |connection|
            channel = AMQP::Channel.new(connection)
            exchange = channel.fanout('logs')
            queue = channel.queue('', :exclusive => true)

            queue.bind(exchange)

            Signal.trap('INT') do
              connection.close do
                EM.stop { exit }
              end
            end

            puts ' [*] Waiting for logs. To exit press CTRL+C'

            queue.subscribe do |body|
              respond_to do |format|
                format.js { render :js => "alert(#{body})" }
              end
            end
          end
        rescue AMQP::TCPConnectionFailed => e
          puts "Caught AMQP::TCPConnectionFailed => TCP connection failed, as expected. #{e}"
        end

    end
  end
=end

end
