<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('tbl_order', function (Blueprint $table) {
            $table->bigIncrements('v_orderId');

            $table->string('v_orderNumber', 60)
                ->nullable()
                ->unique();

            $table->unsignedBigInteger('v_customerId');

            $table->dateTime('v_orderDate')
                ->useCurrent();

            $table->string('v_orderStatus', 50)
                ->nullable();

            $table->decimal('v_subtotalAmount', 14, 2)
                ->nullable();

            $table->decimal('v_discountAmount', 14, 2)
                ->default(0.00);

            $table->decimal('v_deliveryFee', 14, 2)
                ->default(0.00);

            $table->decimal('v_taxAmount', 14, 2)
                ->default(0.00);

            $table->decimal('v_totalAmount', 14, 2)
                ->nullable();

            $table->text('v_orderNotes')
                ->nullable();

            $table->dateTime('v_createdAt')
                ->useCurrent();

            $table->dateTime('v_updatedAt')
                ->useCurrent();

            $table->foreign('v_customerId', 'fk_order_customer')
                ->references('v_customerId')
                ->on('tbl_customer')
                ->onUpdate('cascade')
                ->onDelete('restrict');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('tbl_order');
    }
};