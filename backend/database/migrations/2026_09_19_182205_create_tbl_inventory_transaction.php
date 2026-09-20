<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('tbl_inventoryTransaction', function (Blueprint $table) {
            $table->bigIncrements('v_inventoryTransactionId');

            $table->unsignedBigInteger('v_inventoryId');

            $table->string('v_transactionType', 50)
                ->nullable();

            $table->decimal('v_quantity', 14, 2);

            $table->string('v_referenceType', 50)
                ->nullable();

            $table->unsignedBigInteger('v_referenceId')
                ->nullable();

            $table->dateTime('v_transactionDate')
                ->useCurrent();

            $table->string('v_reason', 255)
                ->nullable();

            $table->unsignedBigInteger('v_performedByUserId')
                ->nullable();

            $table->text('v_notes')
                ->nullable();

            $table->foreign(
                'v_inventoryId',
                'fk_inventoryTransaction_inventory'
            )
                ->references('v_inventoryId')
                ->on('tbl_inventory')
                ->onUpdate('cascade')
                ->onDelete('restrict');

            $table->foreign(
                'v_performedByUserId',
                'fk_inventoryTransaction_user'
            )
                ->references('v_userId')
                ->on('tbl_user')
                ->onUpdate('cascade')
                ->onDelete('set null');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('tbl_inventoryTransaction');
    }
};